import 'package:flutter/material.dart';
import '../utils/rut_utils.dart';

class RutText extends StatelessWidget {
  final String rut;
  final TextStyle? style;

  const RutText(this.rut, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatRut(rut),
      style: style ?? const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}