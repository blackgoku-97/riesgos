import 'package:flutter/material.dart';
import 'matriz_riesgo.dart';

class FrecuenciaSeveridadFields extends StatelessWidget {
  final int? frecuencia;
  final int? severidad;
  final String? nivelRiesgo;
  final ValueChanged<int?> onFrecuenciaChanged;
  final ValueChanged<int?> onSeveridadChanged;

  const FrecuenciaSeveridadFields({
    super.key,
    required this.frecuencia,
    required this.severidad,
    required this.nivelRiesgo,
    required this.onFrecuenciaChanged,
    required this.onSeveridadChanged,
  });

  Color _colorPorNivel(String? nivel) {
    if (nivel == 'Aceptable') return Colors.green;
    if (nivel == 'No Aceptable') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          initialValue: frecuencia,
          decoration: const InputDecoration(
            labelText: 'Frecuencia (1-5)',
            border: OutlineInputBorder(),
          ),
          items: List.generate(5, (i) => i + 1)
              .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
              .toList(),
          onChanged: onFrecuenciaChanged,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          initialValue: severidad,
          decoration: const InputDecoration(
            labelText: 'Severidad (1-5)',
            border: OutlineInputBorder(),
          ),
          items: List.generate(5, (i) => i + 1)
              .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
              .toList(),
          onChanged: onSeveridadChanged,
        ),
        const SizedBox(height: 8),
        Text(
          'Nivel de Riesgo: ${nivelRiesgo ?? '—'}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _colorPorNivel(nivelRiesgo),
          ),
        ),
        const MatrizRiesgo(),
        const SizedBox(height: 16),
      ],
    );
  }
}