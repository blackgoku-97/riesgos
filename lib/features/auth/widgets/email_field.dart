import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final String? errorText;

  const EmailField({
    super.key,
    required this.controller,
    required this.isValid,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        errorText: errorText, // 👈 mensaje debajo del campo
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