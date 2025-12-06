import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/tarjeta_utils_planificacion.dart';

class HistorialPlanificacionesScreen extends StatefulWidget {
  const HistorialPlanificacionesScreen({super.key});

  @override
  State<HistorialPlanificacionesScreen> createState() =>
      _HistorialPlanificacionesScreenState();
}

class _HistorialPlanificacionesScreenState extends State<HistorialPlanificacionesScreen> {
  int? anioSeleccionado;

  Future<bool> _obtenerEsAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snap = await FirebaseFirestore.instance
        .collection('perfiles') // 👈 tu colección de perfiles
        .doc(user.uid)
        .get();

    if (!snap.exists) return false;

    final data = snap.data() as Map<String, dynamic>;
    return data['rol'] == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📋 Historial de Planificaciones')),
      body: FutureBuilder<bool>(
        future: _obtenerEsAdmin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final esAdmin = snapshot.data!;

          return StreamBuilder<QuerySnapshot>(
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
                  return TarjetaUtilsPlanificacion(
                    doc: docs[i],
                    esAdmin: esAdmin, // 👈 ahora sí se pasa el flag
                    onEditar: () {
                      Navigator.pushNamed(
                        context,
                        '/duplicar_planificacion',
                        arguments: {
                          'planificacion': docs[i].data() as Map<String, dynamic>,
                        },
                      );
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