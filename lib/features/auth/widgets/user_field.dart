import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UserField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final String label;

  const UserField({
    super.key,
    required this.controller,
    required this.isValid,
    this.label = 'Email o RUT',
  });

  static bool quickValidate(String text, AuthService authService) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    // Si contiene '@', asumimos que es email
    if (trimmed.contains('@')) {
      return authService.isValidEmail(trimmed);
    }

    // Si tiene formato de RUT básico (números + guion + dígito/K)
    final rutPattern = RegExp(r'^\d{1,2}\.?\d{3}\.?\d{3}-[\dkK]$');
    if (rutPattern.hasMatch(trimmed)) {
      return authService.isValidRUT(trimmed.toUpperCase());
    }

    // No es email ni RUT con formato válido
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
      ),
    );
  }
}