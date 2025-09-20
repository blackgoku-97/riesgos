import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UserField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final String? errorText; // 👈 nuevo parámetro opcional
  final String label;

  const UserField({
    super.key,
    required this.controller,
    required this.isValid,
    this.errorText,
    this.label = 'Correo o RUT',
  });

  // Método rápido de validación (puede usarse en LoginScreen)
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
      decoration: InputDecoration(
        labelText: label,
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