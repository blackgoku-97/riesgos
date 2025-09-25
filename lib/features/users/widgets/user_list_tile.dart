import 'package:flutter/material.dart';

class UserListTile extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserListTile({
    super.key,
    required this.usuario,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(usuario['nombre'] ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((usuario['cargo'] ?? '').isNotEmpty)
            Text('Cargo: ${usuario['cargo']}'),
          if ((usuario['email'] ?? '').isNotEmpty)
            Text('Email: ${usuario['email']}'),
          if ((usuario['rutFormateado'] ?? '').isNotEmpty)
            Text('RUT: ${usuario['rutFormateado']}'), // 👈 siempre mostrar formateado
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}