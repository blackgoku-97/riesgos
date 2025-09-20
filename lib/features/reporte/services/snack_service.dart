import 'package:flutter/material.dart';

class SnackService {
  /// Muestra un SnackBar en pantalla
  static void mostrar(BuildContext context, String mensaje, {bool success = false}) {
    final color = success ? Colors.green : Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}