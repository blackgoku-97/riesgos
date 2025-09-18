import 'package:flutter/material.dart';

class SelectorDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> opciones;
  final String Function(T) getLabel;
  final ValueChanged<T?> onChanged;

  const SelectorDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.opciones,
    required this.getLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: opciones.map((o) => DropdownMenuItem(value: o, child: Text(getLabel(o)))).toList(),
      onChanged: onChanged,
    );
  }
}