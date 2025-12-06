import 'package:flutter/material.dart';

class SnackService {
  static void mostrar(BuildContext context, String mensaje, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}