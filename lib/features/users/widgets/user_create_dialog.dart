import 'package:flutter/material.dart';

class UserCreateDialog extends StatefulWidget {
  const UserCreateDialog({super.key});

  @override
  State<UserCreateDialog> createState() => _UserCreateDialogState();
}

class _UserCreateDialogState extends State<UserCreateDialog> {
  final _nombreCtrl = TextEditingController();
  final _cargoCtrl = TextEditingController();
  final _rutCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cargoCtrl.dispose();
    _rutCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Crear nuevo usuario"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: _cargoCtrl, decoration: const InputDecoration(labelText: "Cargo")),
            TextField(controller: _rutCtrl, decoration: const InputDecoration(labelText: "RUT")),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Correo")),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text("Cancelar")),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'nombre': _nombreCtrl.text.trim(),
              'cargo': _cargoCtrl.text.trim(),
              'rut': _rutCtrl.text.trim(),
              'email': _emailCtrl.text.trim(),
              'password': _passCtrl.text.trim(),
            });
          },
          child: const Text("Crear"),
        ),
      ],
    );
  }
}