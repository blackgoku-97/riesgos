import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class UserEditDialog extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const UserEditDialog({super.key, required this.usuario});

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _cargoCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.usuario['nombre']);
    _cargoCtrl = TextEditingController(text: widget.usuario['cargo']);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar usuario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: _cargoCtrl,
            decoration: const InputDecoration(labelText: 'Cargo'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nombreCtrl.text.trim().isEmpty || _cargoCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nombre y cargo no pueden estar vacíos')),
              );
              return;
            }
            Navigator.pop(context, {
              'nombre': _nombreCtrl.text.trim(),
              'cargo': _cargoCtrl.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}