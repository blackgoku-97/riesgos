import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggleVisibility;

  /// Si este campo es de confirmación, recibe el controlador de la contraseña original
  final TextEditingController? originalController;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggleVisibility,
    this.originalController,
  });

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    final isValid = text.isNotEmpty && text.length <= 8;

    String? errorText;

    // Validación de confirmación
    if (originalController != null) {
      if (text.isNotEmpty && text != originalController!.text) {
        errorText = "Las contraseñas no coinciden";
      }
    } else {
      if (text.isNotEmpty && !isValid) {
        errorText = "La contraseña debe tener máximo 8 caracteres";
      }
    }

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      inputFormatters: [
        LengthLimitingTextInputFormatter(8),
      ],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        helperText: originalController == null ? "Máximo 8 caracteres" : "",
        helperStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        errorText: errorText,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}