import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/reporte_service.dart';
import '../services/snack_service.dart';

class HistorialReportesScreen extends StatelessWidget {
  const HistorialReportesScreen({super.key});

  Future<void> _eliminarReporte(BuildContext context, String id) async {
    try {
      await ReporteService.eliminar(id);
      if (!context.mounted) return;
      SnackService.mostrar(context, "Reporte eliminado", success: true);
    } catch (e) {
      SnackService.mostrar(context, "Error al eliminar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Reportes")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reportes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar reportes"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No hay reportes registrados"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;
              final lugar = data['lugar'] ?? '—';
              final tipo = data['tipoAccidente'] ?? '—';
              final potencial = data['potencial']?.toString() ?? '—';
              final fecha = (data['createdAt'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text("$tipo en $lugar"),
                  subtitle: Text(
                    "Potencial: $potencial\n${fecha != null ? fecha.toString() : "Sin fecha"}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'ver') {
                        // Aquí podrías navegar a un DetalleReporteScreen
                      } else if (value == 'editar') {
                        // Aquí podrías navegar a CrearReporteScreen con datos cargados
                      } else if (value == 'eliminar') {
                        _eliminarReporte(context, id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'ver', child: Text("Ver")),
                      const PopupMenuItem(value: 'editar', child: Text("Editar")),
                      const PopupMenuItem(value: 'eliminar', child: Text("Eliminar")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}