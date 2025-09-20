import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistorialReportesScreen extends StatefulWidget {
  const HistorialReportesScreen({super.key});

  @override
  State<HistorialReportesScreen> createState() => _HistorialReportesScreenState();
}

class _HistorialReportesScreenState extends State<HistorialReportesScreen> {
  int? anioSeleccionado;

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

  Widget _tarjetaReporte(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final info = [
      '📅 Fecha: ${data['fechaReporteLocal'] ?? ''}',
      '👤 Cargo: ${data['cargo'] ?? ''}',
      '📍 Lugar: ${data['lugarEspecifico'] ?? ''}',
      '⚠️ Tipo accidente: ${data['tipoAccidente'] ?? ''}',
      '💥 Lesión: ${data['lesion'] ?? ''}',
      '🔧 Actividad: ${data['actividad'] ?? ''}',
      '👥 Afectado: ${data['quienAfectado'] ?? ''}',
      '📉 Potencial: ${data['potencial'] ?? ''}',
      '📝 Descripción: ${data['descripcion'] ?? ''}',
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
            const SizedBox(height: 8),
            ...info.map((t) => Text(t)),
            if (data['imagen'] != null && data['imagen'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['imagen'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildButton(
                  text: 'Exportar Excel',
                  color: Colors.green,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Exportar a Excel")),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildButton(
                  text: 'Exportar PDF',
                  color: Colors.red,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Exportar a PDF")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildButton(
                  text: 'Editar',
                  color: Colors.blue,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Editar reporte")),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildButton(
                  text: 'Eliminar',
                  color: Colors.black,
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Eliminar reporte"),
                        content: const Text("¿Seguro que deseas eliminar este reporte?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancelar"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Eliminar"),
                          ),
                        ],
                      ),
                    );
                    if (confirmar == true) {
                      await FirebaseFirestore.instance
                          .collection('reportes')
                          .doc(doc.id)
                          .delete();
                      if (context.mounted) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Reporte eliminado")),
                        );
                      }
                    }
                  },
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
      appBar: AppBar(title: const Text('📋 Historial de Reportes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reportes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay reportes registrados aún.'));
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return anioSeleccionado == null || data['año'] == anioSeleccionado;
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No hay reportes para ese año.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, i) => _tarjetaReporte(docs[i]),
          );
        },
      ),
    );
  }
}