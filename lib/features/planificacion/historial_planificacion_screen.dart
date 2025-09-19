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

class _HistorialPlanificacionesScreenState extends State<HistorialPlanificacionesScreen> {
  int? anioSeleccionado;

  final espacio8 = const SizedBox(height: 8);
  final espacio12 = const SizedBox(height: 12);

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _tarjetaPlanificacion(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final info = [
      '📅 Fecha: ${data['fechaPlanificacionLocal'] ?? ''}',
      '📌 Plan de trabajo: ${data['planTrabajo'] ?? ''}',
      '📍 Área: ${data['area'] ?? ''}',
      '🔄 Proceso: ${data['proceso'] ?? ''}',
      '🔧 Actividad: ${data['actividad'] ?? ''}',
      '⚠️ Peligros: ${(data['peligros'] as List?)?.join(", ") ?? "—"}',
      '🧪 Agente Material: ${(data['agenteMaterial'] as List?)?.join(", ") ?? "—"}',
      '🛡️ Medidas: ${(data['medidas'] as List?)?.join(", ") ?? "—"}',
      '📉 Riesgo: ${data['nivelRiesgo'] ?? ''}',
    ];

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
            ...info.map((t) => Text(t)),
            if (data['urlImagen'] != null) ...[
              espacio8,
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['urlImagen'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            espacio12,
            Row(
              children: [
                _buildButton(
                  text: 'Exportar Excel',
                  color: Colors.green,
                  onPressed: () => ExportUtils.exportarExcel(data),
                ),
                const SizedBox(width: 8),
                _buildButton(
                  text: 'Exportar PDF',
                  color: Colors.red,
                  onPressed: () => ExportUtils.exportarPDF(data),
                ),
              ],
            ),
            espacio8,
            Row(
              children: [
                _buildButton(
                  text: 'Editar Planificación',
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/duplicar_planificacion',
                      arguments: {
                        'data': data,
                        'origenId': doc.id,
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildButton(
                  text: 'Eliminar Planificación',
                  color: Colors.red,
                  onPressed: () => DeleteUtils.confirmarYEliminarPlanificacion(
                    context: context,
                    id: doc.id,
                    urlImagen: data['urlImagen'],
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
            return const Center(child: Text('No hay planificaciones registradas aún.'));
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return anioSeleccionado == null || data['año'] == anioSeleccionado;
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No hay planificaciones para ese año.'));
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