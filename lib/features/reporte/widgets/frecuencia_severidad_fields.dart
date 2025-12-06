import 'package:flutter/material.dart';
import 'matriz_potencial.dart';

class FrecuenciaSeveridadFields extends StatelessWidget {
  final int? frecuencia, severidad;
  final String? nivelPotencial;
  final ValueChanged<int?> onFrecuenciaChanged, onSeveridadChanged;

  const FrecuenciaSeveridadFields({
    super.key,
    required this.frecuencia,
    required this.severidad,
    required this.nivelPotencial,
    required this.onFrecuenciaChanged,
    required this.onSeveridadChanged,
  });

  Color _colorPorNivel(String? nivel) {
    if (nivel == 'Alto') return Colors.green;
    if (nivel == 'Bajo') return Colors.red;
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
          'Nivel de Potencial: ${nivelPotencial ?? '—'}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _colorPorNivel(nivelPotencial),
          ),
        ),
        const MatrizPotencial(),
        const SizedBox(height: 16),
      ],
    );
  }
}