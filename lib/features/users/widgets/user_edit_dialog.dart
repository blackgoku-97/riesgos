import 'package:flutter/material.dart';

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
    _rutCtrl = TextEditingController(text: widget.usuario['rut']);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cargoCtrl.dispose();
    _rutCtrl.dispose();
    super.dispose();
  }

  bool _validarRut(String rut) {
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
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese un nombre' : null,
              ),
              TextFormField(
                controller: _cargoCtrl,
                decoration: const InputDecoration(labelText: 'Cargo'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese un cargo' : null,
              ),
              TextFormField(
                controller: _rutCtrl,
                decoration: const InputDecoration(labelText: 'RUT'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese un RUT';
                  if (!_validarRut(v.trim())) return 'RUT inválido';
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
              Navigator.pop(context, {
                'nombre': _nombreCtrl.text.trim(),
                'cargo': _cargoCtrl.text.trim(),
                'rut': _rutCtrl.text.trim(),
              });
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}