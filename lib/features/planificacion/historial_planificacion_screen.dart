import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../planificacion/utils/export_utils.dart';
import '../planificacion/utils/delete_utils.dart';

class HistorialPlanificacionesScreen extends StatefulWidget {
  const HistorialPlanificacionesScreen({super.key});
  @override
  State<HistorialPlanificacionesScreen> createState() =>
      _HistorialPlanificacionesScreenState();
}

class _HistorialPlanificacionesScreenState
    extends State<HistorialPlanificacionesScreen> {
  int? anioSeleccionado;

  Widget _tarjetaPlanificacion(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['numeroPlanificacion'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text('📅 Fecha: ${data['fechaPlanificacionLocal'] ?? ''}'),
            Text('📌 Plan de trabajo: ${data['planTrabajo'] ?? ''}'),
            const SizedBox(height: 8),
            Text('📍 Área: ${data['area'] ?? ''}'),
            Text('🔄 Proceso: ${data['proceso'] ?? ''}'),
            Text('🔧 Actividad: ${data['actividad'] ?? ''}'),
            Text(
              '⚠️ Peligros: ${(data['peligros'] as List?)?.join(", ") ?? "—"}',
            ),
            Text(
              '🧪 Agente Material: ${(data['agenteMaterial'] as List?)?.join(", ") ?? "—"}',
            ),
            Text(
              '🛡️ Medidas: ${(data['medidas'] as List?)?.join(", ") ?? "—"}',
            ),
            Text('📉 Riesgo: ${data['nivelRiesgo'] ?? ''}'),
            if (data['urlImagen'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    data['urlImagen'],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => ExportUtils.exportarExcel(data),
                    child: const Text(
                      'Exportar Excel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => ExportUtils.exportarPDF(data),
                    child: const Text(
                      'Exportar PDF',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/duplicar_planificacion',
                        arguments: {
                          'data':
                              data, // Mapa con los datos de la planificación
                          'origenId': doc.id, // ID del documento original
                        },
                      );
                    },
                    child: const Text(
                      'Editar Planificación',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () =>
                        DeleteUtils.confirmarYEliminarPlanificacion(
                          context: context,
                          id: doc.id,
                          urlImagen: data['urlImagen'],
                        ),
                    child: const Text(
                      'Eliminar Planificación',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📋 Historial de Planificaciones')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('planificaciones')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay planificaciones registradas aún.'),
            );
          }
          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (anioSeleccionado == null) return true;
            return data['año'] == anioSeleccionado;
          }).toList();
          if (docs.isEmpty) {
            return const Center(
              child: Text('No hay planificaciones para ese año.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, i) => _tarjetaPlanificacion(docs[i]),
          );
        },
      ),
    );
  }
}
