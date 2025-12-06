import 'dart:io';

class ValidacionService {
  static String? validarReporte({
    required String? lugar,
    required String? tipoAccidente,
    required String? rol,
    required String? cargo,
    required List<String>? lesiones,
    required String? actividad,
    required String? clasificacion,
    required List<String>? accionesInseguras,
    required List<String>? condicionesInseguras,
    required List<String>? medidas,
    required String? quienAfectado,
    required String? descripcion,
    int? frecuencia,
    int? severidad,
    File? imagen,
  }) {
    // Lugar
    if (lugar == null || lugar.isEmpty) {
      return "Debe ingresar el lugar del incidente";
    }

    // A quién le ocurrió
    if (quienAfectado == null || quienAfectado.isEmpty) {
      return "Debe seleccionar a quién le ocurrió";
    }

    // Tipo de accidente
    if (tipoAccidente == null || tipoAccidente.isEmpty) {
      return "Debe seleccionar el tipo de accidente";
    }

    // Cargo
    if (cargo == null || cargo.isEmpty) {
      return "No se pudo obtener el cargo del usuario";
    }

    // Lesiones (obligatorias salvo cuasi accidente)
    if (tipoAccidente != "Cuasi Accidente") {
      if (lesiones == null || lesiones.isEmpty) {
        return "Debe seleccionar al menos un tipo de lesión";
      }
    }

    // Actividad
    if (actividad == null || actividad.isEmpty) {
      return "Debe seleccionar la actividad";
    }

    // Clasificación
    if (clasificacion == null || clasificacion.isEmpty) {
      return "Debe seleccionar la clasificación";
    }

    // Acciones inseguras
    if (clasificacion == "Acción Insegura") {
      if (accionesInseguras == null || accionesInseguras.isEmpty) {
        return "Debe seleccionar al menos una acción insegura";
      }
    }

    // Condiciones inseguras
    if (clasificacion == "Condición Insegura") {
      if (condicionesInseguras == null || condicionesInseguras.isEmpty) {
        return "Debe seleccionar al menos una condición insegura";
      }
    }

    // Medidas preventivas
    if (medidas == null || medidas.isEmpty) {
      return "Debe seleccionar al menos una medida preventiva";
    }

    // Descripción
    if (descripcion == null || descripcion.isEmpty) {
      return "Debe ingresar una descripción";
    }

    if ((rol ?? '') == 'admin') {
      if (frecuencia == null) return 'Debes seleccionar la frecuencia';
      if (severidad == null) return 'Debes seleccionar la severidad';
    }

    return null; // ✅ Todo válido
  }
}