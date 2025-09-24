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
      dv = text.substring(text.length - 1).toUpperCase();
    }

    // Insertar puntos cada 3 dígitos desde la derecha
    final buffer = StringBuffer();
    int counter = 0;
    for (int i = body.length - 1; i >= 0; i--) {
      buffer.write(body[i]);
      counter++;
      if (counter == 3 && i != 0) {
        buffer.write('.');
        counter = 0;
      }
    }

    // Invertir porque lo construimos al revés
    String formattedBody = buffer.toString().split('').reversed.join();

    // Agregar guion si hay dígito verificador
    String formatted = dv.isNotEmpty ? '$formattedBody-$dv' : formattedBody;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}