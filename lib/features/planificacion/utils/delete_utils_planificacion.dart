import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DeleteUtilsPlanificacion {
  static Future<void> confirmarYEliminarPlanificacion({
    required BuildContext context,
    required String id,
    String? urlImagen,
  }) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Seguro que deseas eliminar esta planificación?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmar == true) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        if (urlImagen != null && urlImagen.isNotEmpty) {
          final ref = firebase_storage.FirebaseStorage.instance.refFromURL(urlImagen);
          await ref.delete();
        }
        await FirebaseFirestore.instance.collection('planificaciones').doc(id).delete();

        if (!context.mounted) return;
        Navigator.pop(context); // Cierra loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Planificación e imagen eliminadas')),
        );
      } catch (e) {
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }
}