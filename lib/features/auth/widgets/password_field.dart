import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggleVisibility;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggleVisibility, required bool isValid, required String helperText, String? errorText,
  });

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    final isValid = text.length == 8; // 👈 exactamente 8 caracteres

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      inputFormatters: [
        LengthLimitingTextInputFormatter(8), // 👈 máximo 8
      ],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        helperText: "Debe tener exactamente 8 caracteres",
        helperStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        errorText: text.isNotEmpty && !isValid
            ? "La contraseña debe tener exactamente 8 caracteres"
            : null,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: onToggleVisibility,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: text.isEmpty
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
            color: text.isEmpty
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