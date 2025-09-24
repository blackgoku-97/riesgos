import 'package:flutter/material.dart';
import '../utils/rut_utils.dart';

class UserEditDialog extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const UserEditDialog({super.key, required this.usuario});

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _cargoCtrl;
  late TextEditingController _rutCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.usuario['nombre']);
    _cargoCtrl = TextEditingController(text: widget.usuario['cargo']);
    _rutCtrl = TextEditingController(
      text: formatRut(widget.usuario['rut'] ?? ''),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cargoCtrl.dispose();
    _rutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar usuario'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingrese un nombre' : null,
              ),
              TextFormField(
                controller: _cargoCtrl,
                decoration: const InputDecoration(labelText: 'Cargo'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingrese un cargo' : null,
              ),
              TextFormField(
                controller: _rutCtrl,
                decoration: const InputDecoration(labelText: 'RUT'),
                inputFormatters: [RutInputFormatter()],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese un RUT';
                  if (!validarRut(v.trim())) return 'RUT inválido';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final rutFormateado = _rutCtrl.text.trim().toUpperCase();
              final rutLimpio = rutFormateado.replaceAll('.', '').replaceAll('-', '');

              Navigator.pop(context, {
                'nombre': _nombreCtrl.text.trim(),
                'cargo': _cargoCtrl.text.trim(),
                'rut': rutLimpio,          // 👈 para búsquedas
                'rutFormateado': rutFormateado, // 👈 para mostrar
              });
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}