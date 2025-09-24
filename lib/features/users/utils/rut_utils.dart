import 'package:flutter/services.dart';

/// Formatea un RUT en tiempo real con puntos y guion
class RutInputFormatter extends TextInputFormatter {
  static const int maxLength = 10; // 9 dígitos + DV

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9kK]'), '');

    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // separar cuerpo y dígito verificador
    String body = text;
    String dv = '';
    if (text.length > 1) {
      body = text.substring(0, text.length - 1);
      dv = text.substring(text.length - 1).toUpperCase();
    }

    // insertar puntos cada 3 dígitos desde la derecha
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

/// Valida que el RUT tenga un dígito verificador correcto
bool validarRut(String rut) {
  rut = rut.replaceAll('.', '').replaceAll('-', '').toUpperCase();
  if (rut.length < 2) return false;

  final cuerpo = rut.substring(0, rut.length - 1);
  final dv = rut.substring(rut.length - 1);

  int suma = 0, multiplo = 2;
  for (int i = cuerpo.length - 1; i >= 0; i--) {
    suma += int.parse(cuerpo[i]) * multiplo;
    multiplo = multiplo == 7 ? 2 : multiplo + 1;
  }

  final dvEsperado = 11 - (suma % 11);
  final dvStr = dvEsperado == 11 ? '0' : dvEsperado == 10 ? 'K' : dvEsperado.toString();

  return dvStr == dv;
}

/// Formatea un RUT ya guardado (ej. en Firestore) para mostrarlo
String formatRut(String rut) {
  rut = rut.replaceAll('.', '').replaceAll('-', '').toUpperCase();
  if (rut.isEmpty) return '';

  String body = rut.substring(0, rut.length - 1);
  String dv = rut.substring(rut.length - 1);

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
  return '$formattedBody-$dv';
}