import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggleVisibility;
  final bool isValid;
  final String helperText;
  final String? errorText;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggleVisibility,
    required this.isValid,
    this.helperText = '',
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        helperText: helperText.isNotEmpty ? helperText : null,
        helperStyle: const TextStyle(color: Colors.white54),
        errorText: errorText, // 👈 mensaje debajo del campo
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