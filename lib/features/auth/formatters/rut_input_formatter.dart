import 'package:flutter/services.dart';

class RutInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9kK]'), '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String body = text;
    String dv = '';
    if (text.length > 1) {
      body = text.substring(0, text.length - 1);
      dv = text.substring(text.length - 1).toUpperCase();
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

    String formattedBody = buffer.toString().split('').reversed.join();
    String formatted = dv.isNotEmpty ? '$formattedBody-$dv' : formattedBody;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}