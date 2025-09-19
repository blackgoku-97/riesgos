import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../planificacion/widgets/tarjeta_planificacion.dart';

class HistorialPlanificacionesScreen extends StatefulWidget {
  const HistorialPlanificacionesScreen({super.key});

  @override
  State<HistorialPlanificacionesScreen> createState() =>
      _HistorialPlanificacionesScreenState();
}

class _HistorialPlanificacionesScreenState extends State<HistorialPlanificacionesScreen> {
  int? anioSeleccionado;

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
            itemBuilder: (context, i) {
              return TarjetaPlanificacion(
                doc: docs[i],
                onEditar: () {
                  Navigator.pushNamed(
                    context,
                    '/duplicar_planificacion',
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