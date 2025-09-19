import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/opciones_area.dart';

class ValidacionService {
  static String? validar({
    required String plan,
    required String? area,
    String? proceso,
    String? actividad,
    List<String>? peligros,
    List<String>? agenteMaterial,
    List<String>? medidas,
    required LatLng? ubicacion,
    required String? rol,
    required String? cargo, // nuevo
    required int? frecuencia,
    required int? severidad,
    File? imagen,
  }) {
    if (plan.trim().isEmpty) return 'Debes ingresar el plan de trabajo';
    if (area == null) return 'Debes seleccionar un área de trabajo';
    if (ubicacion == null) return 'No se pudo obtener la ubicación';
    if (cargo == null || cargo.trim().isEmpty) {
      return 'No se pudo obtener el cargo del usuario';
    }

    final areaEnum = opcionesArea.firstWhere(
      (a) => a.label == area,
      orElse: () => Area.seleccionar,
    );

    if (opcionesProceso[areaEnum]!.isNotEmpty &&
        (proceso == null || proceso.isEmpty)) {
      return 'Debes seleccionar un proceso';
    }
    if (opcionesActividad[areaEnum]!.isNotEmpty &&
        (actividad == null || actividad.isEmpty)) {
      return 'Debes seleccionar una actividad';
    }
    if (opcionesPeligro[areaEnum]!.isNotEmpty &&
        (peligros == null || peligros.isEmpty)) {
      return 'Debes seleccionar al menos un peligro';
    }
    if (opcionesAgenteMaterial[areaEnum]!.isNotEmpty &&
        (agenteMaterial == null || agenteMaterial.isEmpty)) {
      return 'Debes seleccionar al menos un agente material';
    }
    if (medidas == null || medidas.isEmpty) {
      return 'Debes seleccionar al menos una medida';
    }
    if (imagen == null) {
      return 'Debes tomar una foto de la actividad';
    }
    if ((rol ?? '') == 'admin') {
      if (frecuencia == null) return 'Debes seleccionar la frecuencia';
      if (severidad == null) return 'Debes seleccionar la severidad';
    }
    return null;
  }
}