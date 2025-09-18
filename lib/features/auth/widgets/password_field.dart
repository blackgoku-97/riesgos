import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggleVisibility;
  final bool isValid;
  final String helperText;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggleVisibility,
    required this.isValid,
    required this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white10,
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
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          helperText,
          style: TextStyle(
            color: controller.text.isEmpty
                ? Colors.white54
                : isValid
                    ? Colors.green
                    : Colors.redAccent,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}