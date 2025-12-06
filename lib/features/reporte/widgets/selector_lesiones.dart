import 'package:flutter/material.dart';

class SelectorLesiones extends StatelessWidget {
  final List<String> opciones;
  final List<String> seleccionadas;
  final ValueChanged<List<String>> onChanged;

  const SelectorLesiones({
    super.key,
    required this.opciones,
    required this.seleccionadas,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final temp = List<String>.from(seleccionadas);
        final resultado = await showDialog<List<String>>(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  title: const Text('Selecciona tipo(s) de lesión'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      children: opciones.map((lesion) {
                        final checked = temp.contains(lesion);
                        return CheckboxListTile(
                          value: checked,
                          title: Text(lesion, overflow: TextOverflow.ellipsis),
                          onChanged: (v) {
                            setStateDialog(() {
                              v == true ? temp.add(lesion) : temp.remove(lesion);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, temp),
                      child: const Text('Aceptar'),
                    ),
                  ],
                );
              },
            );
          },
        );
        if (resultado != null) onChanged(resultado);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Tipo de lesión",
          border: OutlineInputBorder(),
        ),
        child: Text(
          seleccionadas.isEmpty
              ? 'Toca para seleccionar'
              : seleccionadas.join(', '),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}