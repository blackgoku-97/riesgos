import 'package:flutter/services.dart';

class RutInputFormatter extends TextInputFormatter {
  static const int maxLength = 10; // 9 dígitos + DV

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Eliminar todo lo que no sea dígito o K
    String text = newValue.text.replaceAll(RegExp(r'[^0-9kK]'), '');

    // Limitar a 10 caracteres máximo
    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Separar cuerpo y dígito verificador
    String body = text;
    String dv = '';
    if (text.length > 1) {
      body = text.substring(0, text.length - 1);
      dv = text.substring(text.length - 1);
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