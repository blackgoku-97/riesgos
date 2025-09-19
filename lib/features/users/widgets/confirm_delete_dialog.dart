import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Eliminar usuario'),
      content: const Text(
        '¿Seguro que quieres eliminar este usuario? Esto borrará su cuenta y su perfil.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}