import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PlanificacionService {
  static Future<void> guardar({
    required String cargo,        // nuevo
    required String? rol,         // nuevo
    required String planTrabajo,
    required String area,
    String? proceso,
    String? actividad,
    List<String>? peligros,
    List<String>? agenteMaterial,
    List<String>? medidas,
    required LatLng ubicacion,
    int? frecuencia,
    int? severidad,
    String? nivelRiesgo,
    String? urlImagen,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // Contar planificaciones existentes para generar el número correlativo
    final countSnap = await FirebaseFirestore.instance
        .collection('planificaciones')
        .count()
        .get();

    final numero = (countSnap.count ?? 0) + 1;
    final numeroFormateado = numero.toString().padLeft(3, '0'); // 001, 002, 003...
    final anio = DateTime.now().year;
    final numeroPlanificacion = 'Planificación $numeroFormateado - $anio';

    await FirebaseFirestore.instance.collection('planificaciones').add({
      'numeroPlanificacion': numeroPlanificacion,
      'año': anio,
      'fechaPlanificacionLocal':
          DateFormat('dd/MM/yyyy', 'es_CL').format(DateTime.now()),
      'cargo': cargo,        // nuevo
      'rol': rol,            // nuevo
      'planTrabajo': planTrabajo,
      'area': area,
      'proceso': proceso,
      'actividad': actividad,
      'peligros': peligros,
      'agenteMaterial': agenteMaterial,
      'medidas': medidas,
      'frecuencia': frecuencia,
      'severidad': severidad,
      'nivelRiesgo': nivelRiesgo,
      'ubicacion': GeoPoint(ubicacion.latitude, ubicacion.longitude),
      'urlImagen': urlImagen,
      'uid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}