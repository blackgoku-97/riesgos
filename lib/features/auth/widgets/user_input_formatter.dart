import 'package:flutter/services.dart';

class UserInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.trim();

    // Si contiene '@', tratamos como email
    if (text.contains('@')) {
      // Asegurar que solo haya un '@'
      final parts = text.split('@');
      if (parts.length > 2) {
        text = '${parts[0]}@${parts.sublist(1).join('')}';
      }
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    // Si no contiene '@', tratamos como RUT
    String clean = text.replaceAll(RegExp(r'[^0-9kK]'), '');

    if (clean.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Separar cuerpo y dígito verificador
    String body = clean;
    String dv = '';
    if (clean.length > 1) {
      body = clean.substring(0, clean.length - 1);
      dv = clean.substring(clean.length - 1);
    }

    // Insertar puntos cada 3 dígitos desde la derecha
    final buffer = StringBuffer();
    for (int i = 0; i < body.length; i++) {
      int position = body.length - i;
      buffer.write(body[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }

    String formatted = buffer.toString();

    // Agregar guion si hay dígito verificador
    if (dv.isNotEmpty) {
      formatted += '-$dv';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}