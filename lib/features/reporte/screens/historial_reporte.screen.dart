import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistorialReportesScreen extends StatefulWidget {
  const HistorialReportesScreen({super.key});

  @override
  State<HistorialReportesScreen> createState() =>
      _HistorialReportesScreenState();
}

class _HistorialReportesScreenState extends State<HistorialReportesScreen> {
  int? anioSeleccionado;

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
            final fecha = (data['createdAt'] as Timestamp?)?.toDate();
            return anioSeleccionado == null ||
                (fecha != null && fecha.year == anioSeleccionado);
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No hay reportes para ese año.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;

              final cargo = (data['cargo'] as String?) ?? '—';
              final rol = (data['rol'] as String?) ?? '—';
              final lugar = (data['lugar'] as String?) ?? '—';
              final tipo = (data['tipoAccidente'] as String?) ?? '—';
              final actividad = (data['actividad'] as String?) ?? '—';
              final clasificacion = (data['clasificacion'] as String?) ?? '—';
              final quien = (data['quienAfectado'] as String?) ?? '—';
              final descripcion = (data['descripcion'] as String?) ?? '—';
              final frecuencia = data['frecuencia'];
              final severidad = data['severidad'];
              final potencial = data['potencial'];
              final fecha = (data['createdAt'] as Timestamp?)?.toDate();
              final lat = data['latitud'];
              final lng = data['longitud'];
              final imagen = data['imagen'] as String?;

              final lesiones = _asListStr(data['lesiones']);
              final accionesInseguras = _asListStr(data['accionesInseguras']);
              final condicionesInseguras = _asListStr(data['condicionesInseguras']);
              final medidas = _asListStr(data['medidas']);

              final colorRiesgo = _colorPorPotencial(potencial);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    radius: 10,
                    backgroundColor: colorRiesgo,
                  ),
                  title: Text("$tipo • $lugar"),
                  subtitle: Text(
                    [
                      "Fecha: ${_fmtFecha(fecha)}",
                      "Cargo: $cargo • Rol: $rol",
                      "Actividad: $actividad",
                      if (clasificacion != '—') "Clasificación: $clasificacion",
                      "A quién: $quien",
                    ].join("\n"),
                  ),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _labelValor("Descripción", descripcion),
                    const SizedBox(height: 8),
                    if (lesiones.isNotEmpty) _chipsSection("Lesiones", lesiones),
                    if (accionesInseguras.isNotEmpty)
                      _chipsSection("Acciones inseguras", accionesInseguras),
                    if (condicionesInseguras.isNotEmpty)
                      _chipsSection("Condiciones inseguras", condicionesInseguras),
                    if (medidas.isNotEmpty) _chipsSection("Medidas", medidas),
                    const SizedBox(height: 8),
                    _labelValor(
                      "Riesgo/potencial",
                      (frecuencia != null && severidad != null && potencial != null)
                          ? "Frecuencia: $frecuencia • Severidad: $severidad • Potencial: $potencial"
                          : "—",
                    ),
                    const SizedBox(height: 8),
                    _labelValor(
                      "Ubicación",
                      (lat != null && lng != null) ? "$lat, $lng" : "—",
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Duplicar'),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/duplicar_reporte',
                              arguments: {
                                'data': data,
                                'origenId': id,
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Detalle'),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/detalle_reporte',
                              arguments: {'id': id},
                            );
                          },
                        ),
                        const Spacer(),
                        if (imagen != null)
                          Tooltip(
                            message: 'Tiene imagen adjunta',
                            child: const Icon(Icons.image, size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helpers

  List<String> _asListStr(dynamic v) {
    if (v is List) {
      return v.whereType<String>().toList();
    }
    return const [];
    // Si guardas arrays heterogéneos, podrías hacer:
    // return (v as List?)?.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList() ?? const [];
  }

  String _fmtFecha(DateTime? d) {
    if (d == null) return '—';
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$day-$m-$y";
  }

  Color _colorPorPotencial(dynamic p) {
    if (p is num) {
      if (p <= 4) return Colors.green;
      if (p <= 9) return Colors.orange;
      return Colors.red;
    }
    return Colors.grey;
  }

  Widget _labelValor(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Text(valor),
      ],
    );
  }

  Widget _chipsSection(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: -6,
            children: items.map((e) => Chip(label: Text(e))).toList(),
          ),
        ],
      ),
    );
  }
}