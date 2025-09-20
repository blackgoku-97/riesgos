import 'package:flutter/services.dart';

class EmailAutoAtFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Si el usuario escribió algo y aún no hay '@', lo agregamos automáticamente
    if (text.isNotEmpty && !text.contains('@')) {
      text = '$text@';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}