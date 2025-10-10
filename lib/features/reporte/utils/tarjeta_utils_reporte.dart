import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'export_utils_reporte.dart';
import 'delete_utils_reporte.dart';

class TarjetaUtilsReporte extends StatelessWidget {
  final DocumentSnapshot doc;
  final VoidCallback onEditar;
  final bool esAdmin;

  const TarjetaUtilsReporte({
    super.key,
    required this.doc,
    required this.onEditar,
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
    final puedeVerPotencial = esAdmin || creadoPorRol == 'admin';

    final info = [
      '📅 Fecha: ${data['fechaReporteLocal'] ?? ''}',
      '👤 Cargo: ${data['cargo'] ?? ''}',
      '📍 Lugar: ${data['lugar'] ?? ''}',
      '💥 Tipo de Accidente: ${data['tipoAccidente'] ?? ''}',
      if (data['tipoAccidente'] != 'Cuasi Accidente')
        '🤕 Lesiones: ${(data['lesiones'] as List?)?.join(", ") ?? "—"}',
      '🔧 Actividad: ${data['actividad'] ?? ''}',
      '📊 Clasificación: ${data['clasificacion'] ?? ''}',
      '⚠️ Acciones Inseguras: ${(data['accionesInseguras'] as List?)?.join(", ") ?? "—"}',
      '🏗️ Condiciones Inseguras: ${(data['condicionesInseguras'] as List?)?.join(", ") ?? "—"}',
      '🛡️ Medidas: ${(data['medidas'] as List?)?.join(", ") ?? "—"}',
      '👥 ¿A quién le ocurrió?: ${data['quienAfectado'] ?? ''}',
      '📝 Descripción: ${data['descripcion'] ?? ''}',
      if (puedeVerPotencial) ...[
        '📈 Frecuencia: ${data['frecuencia'] ?? ''}',
        '📉 Severidad: ${data['severidad'] ?? ''}',
        '🔥 Potencial: ${data['nivelPotencial'] ?? ''}',
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
              data['numeroReporte'] ?? '',
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
                  onPressed: () => ExportUtilsReporte.exportarExcel(data),
                ),
                const SizedBox(width: 8),
                _buildButton(
                  text: 'Exportar PDF',
                  color: Colors.red,
                  onPressed: () => ExportUtilsReporte.exportarPDF(data),
                ),
              ],
            ),
            if (esAdmin) ...[
              espacio8,
              Row(
                children: [
                  _buildButton(
                    text: 'Editar Reporte',
                    color: Colors.black,
                    onPressed: onEditar,
                  ),
                  const SizedBox(width: 8),
                  _buildButton(
                    text: 'Eliminar Reporte',
                    color: Colors.red,
                    onPressed: () => DeleteUtilsReporte.confirmarYEliminarReporte(
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