import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'export_utils_planificacion.dart';
import 'delete_utils_planificacion.dart';

class TarjetaUtilsPlanificacion extends StatelessWidget {
  final DocumentSnapshot doc;
  final VoidCallback onEditar;
  final bool puedeEditar;
  final bool esAdmin;

  const TarjetaUtilsPlanificacion({
    super.key,
    required this.doc,
    required this.onEditar,
    this.puedeEditar = false,
    this.esAdmin = false,
  });

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

  @override
  Widget build(BuildContext context) {
    final espacio8 = const SizedBox(height: 8);
    final espacio12 = const SizedBox(height: 12);
    final data = doc.data() as Map<String, dynamic>;
    final creadoPorRol = data['creadoPorRol'] ?? 'usuario';
    final puedeVerRiesgo = esAdmin || creadoPorRol == 'admin';

    final info = [
      '📅 Fecha: ${data['fechaPlanificacionLocal'] ?? ''}',
      '👤 Cargo: ${data['cargo'] ?? ''}',
      '📌 Plan de trabajo: ${data['planTrabajo'] ?? ''}',
      '📍 Área: ${data['area'] ?? ''}',
      '🔄 Proceso: ${data['proceso'] ?? ''}',
      '🔧 Actividad: ${data['actividad'] ?? ''}',
      '⚠️ Peligros: ${(data['peligros'] as List?)?.join(", ") ?? "—"}',
      '🧪 Agente Material: ${(data['agenteMaterial'] as List?)?.join(", ") ?? "—"}',
      '🛡️ Medidas: ${(data['medidas'] as List?)?.join(", ") ?? "—"}',
      if (puedeVerRiesgo) ...[
        '📊 Frecuencia: ${data['frecuencia'] ?? ''}',
        '📊 Severidad: ${data['severidad'] ?? ''}',
        '📉 Riesgo: ${data['nivelRiesgo'] ?? ''}',
      ],
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
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                ),
              ),
            ],
            espacio12,
            Row(
              children: [
                _buildButton(
                  text: 'Exportar Excel',
                  color: Colors.green,
                  onPressed: () => ExportUtilsPlanificacion.exportarExcel(data),
                ),
                const SizedBox(width: 8),
                _buildButton(
                  text: 'Exportar PDF',
                  color: Colors.red,
                  onPressed: () => ExportUtilsPlanificacion.exportarPDF(data),
                ),
              ],
            ),
            if (puedeEditar) ...[
              espacio8,
              Row(
                children: [
                  _buildButton(
                    text: 'Editar Planificación',
                    color: Colors.black,
                    onPressed: onEditar,
                  ),
                  const SizedBox(width: 8),
                  _buildButton(
                    text: 'Eliminar Planificación',
                    color: Colors.red,
                    onPressed: () => DeleteUtilsPlanificacion.confirmarYEliminarPlanificacion(
                      context: context,
                      id: doc.id,
                      urlImagen: data['urlImagen'],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}