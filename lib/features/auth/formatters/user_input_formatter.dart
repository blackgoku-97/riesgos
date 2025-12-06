import 'package:flutter/services.dart';

class UserInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trim();

    // Si contiene letras (a-z) o '@' → tratamos como email → no formatear
    if (RegExp(r'[a-zA-Z@]').hasMatch(text)) {
      return newValue;
    }

    // Si no, tratamos como RUT
    final clean = text.replaceAll(RegExp(r'[^0-9kK]'), '').toUpperCase();

    if (clean.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String body = clean;
    String dv = '';
    if (clean.length > 1) {
      body = clean.substring(0, clean.length - 1);
      dv = clean.substring(clean.length - 1);
    }

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

    final reversed = buffer.toString().split('').reversed.join();
    String formatted = reversed;

    if (dv.isNotEmpty) {
      formatted += '-$dv';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}