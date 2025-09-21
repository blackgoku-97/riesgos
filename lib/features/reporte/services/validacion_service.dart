import 'dart:io';

class ValidacionService {
  static String? validarReporte({
    required String? lugar,
    required String? tipoAccidente,
    required List<String>? lesiones,
    required String? actividad,
    required String? clasificacion,
    required List<String>? accionesInseguras,
    required List<String>? condicionesInseguras,
    required String? quienAfectado,
    required String? descripcion,
    int? frecuencia,
    int? severidad,
    int? potencial,
    File? imagen,
  }) {
    if (lugar == null || lugar.isEmpty) {
      return "Debe ingresar el lugar del incidente";
    }

    if (quienAfectado == null || quienAfectado.isEmpty) {
      return "Debe seleccionar a quién le ocurrió";
    }

    if (tipoAccidente == null || tipoAccidente.isEmpty) {
      return "Debe seleccionar el tipo de accidente";
    }

    if (tipoAccidente != "Cuasi Accidente") {
      if (lesiones == null || lesiones.isEmpty) {
        return "Debe seleccionar al menos un tipo de lesión";
      }
    }

    if (actividad == null || actividad.isEmpty) {
      return "Debe seleccionar la actividad";
    }

    if (clasificacion == null || clasificacion.isEmpty) {
      return "Debe seleccionar la clasificación";
    }

    if (clasificacion == "Acción Insegura") {
      if (accionesInseguras == null || accionesInseguras.isEmpty) {
        return "Debe seleccionar al menos una acción insegura";
      }
    }

    if (clasificacion == "Condición Insegura") {
      if (condicionesInseguras == null || condicionesInseguras.isEmpty) {
        return "Debe seleccionar al menos una condición insegura";
      }
    }

    if (descripcion == null || descripcion.isEmpty) {
      return "Debe ingresar una descripción";
    }

    if (frecuencia != null && severidad != null) {
      if (potencial == null) {
        return "No se pudo calcular el potencial";
      }
    }

    return null;
  }
}