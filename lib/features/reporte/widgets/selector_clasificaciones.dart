import 'package:flutter/material.dart';

class SelectorClasificaciones extends StatelessWidget {
  final String label;
  final List<String> opciones;
  final List<String> seleccionados;
  final ValueChanged<List<String>> onChanged;

  const SelectorClasificaciones({
    super.key,
    required this.label,
    required this.opciones,
    required this.seleccionados,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final temp = List<String>.from(seleccionados);
        final resultado = await showDialog<List<String>>(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  title: Text('Selecciona $label'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      children: opciones.map((p) {
                        final checked = temp.contains(p);
                        return CheckboxListTile(
                          value: checked,
                          title: Text(p, overflow: TextOverflow.ellipsis),
                          onChanged: (v) {
                            setStateDialog(() {
                              v == true ? temp.add(p) : temp.remove(p);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancelar')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, temp), child: const Text('Aceptar')),
                  ],
                );
              },
            );
          },
        );
        if (resultado != null) onChanged(resultado);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text(
          seleccionados.isEmpty ? 'Toca para seleccionar' : seleccionados.join(', '),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}