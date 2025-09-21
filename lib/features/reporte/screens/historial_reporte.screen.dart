import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/tarjeta_utils_reporte.dart';

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
            return anioSeleccionado == null || data['año'] == anioSeleccionado;
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No hay reportes para ese año.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              return TarjetaUtilsReporte(
                doc: docs[i],
                onEditar: () {
                  Navigator.pushNamed(
                    context,
                    '/duplicar_reporte',
                    arguments: {
                      'data': docs[i].data(),
                      'origenId': docs[i].id,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}