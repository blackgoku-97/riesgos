import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReporteService {
  static Future<void> guardar({
    required String cargo,
    required String rol,
    required String lugar,
    required String tipoAccidente,
    String? lesion,
    required String actividad,
    required String quienAfectado,
    required String descripcion,
    int? frecuencia,
    int? severidad,
    int? potencial, // 🔄 ahora guardamos potencial
    required LatLng ubicacion,
    String? urlImagen,
  }) async {
    final data = {
      'cargo': cargo,
      'rol': rol,
      'lugar': lugar,
      'tipoAccidente': tipoAccidente,
      'lesion': lesion,
      'actividad': actividad,
      'quienAfectado': quienAfectado,
      'descripcion': descripcion,
      'frecuencia': frecuencia,
      'severidad': severidad,
      'potencial': potencial, // 🔄 guardamos aquí
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
}