import 'package:flutter/material.dart';
import '../formatters/rut_input_formatter.dart';

class RutField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final String label;
  final String? errorText; // 👈 nuevo parámetro opcional

  const RutField({
    super.key,
    required this.controller,
    required this.isValid,
    this.label = 'RUT',
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.text,
      inputFormatters: [RutInputFormatter()],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        errorText: errorText, // 👈 aquí se muestra el mensaje
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: controller.text.isEmpty
                ? Colors.transparent
                : isValid
                    ? Colors.green
                    : Colors.red,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: controller.text.isEmpty
                ? Colors.blue
                : isValid
                    ? Colors.green
                    : Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}