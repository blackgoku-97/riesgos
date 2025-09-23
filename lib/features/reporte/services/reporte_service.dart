import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReporteService {
  static Future<void> guardar({
    required String cargo,
    required String? rol,
    required String lugar,
    required String tipoAccidente,
    required List<String> lesiones,
    required String actividad,
    String? clasificacion,
    List<String>? accionesInseguras,
    List<String>? condicionesInseguras,
    List<String>? medidas,
    required String quienAfectado,
    required String descripcion,
    int? frecuencia,
    int? severidad,
    String? nivelPotencial,
    required LatLng ubicacion,
    String? urlImagen,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // Contar reportes existentes para generar el número correlativo
    final countSnap = await FirebaseFirestore.instance
        .collection('reportes')
        .count()
        .get();

    final numero = (countSnap.count ?? 0) + 1;
    final numeroFormateado = numero.toString().padLeft(3, '0'); // 001, 002, 003...
    final anio = DateTime.now().year;
    final numeroReporte = 'Reporte $numeroFormateado - $anio';

    await FirebaseFirestore.instance.collection('reportes').add({
      'numeroReporte': numeroReporte,
      'año': anio,
      'fechaReporteLocal':
          DateFormat('dd/MM/yyyy', 'es_CL').format(DateTime.now()),
      'cargo': cargo,
      'rol': rol,
      'lugar': lugar,
      'tipoAccidente': tipoAccidente,
      'lesiones': lesiones,
      'actividad': actividad,
      'clasificacion': clasificacion,
      'accionesInseguras': accionesInseguras,
      'condicionesInseguras': condicionesInseguras,
      'medidas': medidas,
      'quienAfectado': quienAfectado,
      'descripcion': descripcion,
      'frecuencia': frecuencia,
      'severidad': severidad,
      'nivelPotencial': nivelPotencial,
      'ubicacion': GeoPoint(ubicacion.latitude, ubicacion.longitude),
      'urlImagen': urlImagen,
      'uid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}