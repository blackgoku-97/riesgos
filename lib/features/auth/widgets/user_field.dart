import 'package:flutter/material.dart';
import 'user_input_formatter.dart';
import '../services/auth_service.dart';

class UserField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final String? errorText;

  const UserField({
    super.key,
    required this.controller,
    required this.isValid,
    this.errorText,
  });

  static bool quickValidate(String input, AuthService authService) {
    final text = input.trim();
    if (text.isEmpty) return false;
    return authService.isValidEmail(text) || authService.isValidRUT(text.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.text,
      inputFormatters: [UserInputFormatter()], // 👈 aquí se aplica
      decoration: InputDecoration(
        labelText: 'Correo o RUT',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        errorText: errorText,
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