import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReporteService {
  static Future<void> guardar({
    required String cargo,
    required String rol,
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
    int? potencial,
    required LatLng ubicacion,
    String? urlImagen,
  }) async {
    final data = {
      'cargo': cargo,
      'rol': rol,
      'lugar': lugar,
      'tipoAccidente': tipoAccidente,
      'lesiones': lesiones,
      'actividad': actividad,
      'clasificacion': clasificacion,
      'accionesInseguras': accionesInseguras ?? [],
      'condicionesInseguras': condicionesInseguras ?? [],
      'medidas': medidas ?? [],
      'quienAfectado': quienAfectado,
      'descripcion': descripcion,
      'frecuencia': frecuencia,
      'severidad': severidad,
      'potencial': potencial,
      'latitud': ubicacion.latitude,
      'longitud': ubicacion.longitude,
      'imagen': urlImagen,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('reportes').add(data);
  }

  static Future<void> eliminar(String id) async {
    await FirebaseFirestore.instance.collection('reportes').doc(id).delete();
  }

  static Future<void> actualizar(String id, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('reportes').doc(id).update(data);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> obtenerTodos() {
    return FirebaseFirestore.instance
        .collection('reportes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> obtenerPorId(String id) {
    return FirebaseFirestore.instance.collection('reportes').doc(id).get();
  }
}