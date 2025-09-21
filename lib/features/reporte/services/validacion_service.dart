import 'dart:io';

class ValidacionService {
  static String? validarReporte({
    required String? lugar,
    required String? tipoAccidente,
    required String? actividad,
    required String? clasificacion,
    String? accionInsegura,
    String? condicionInsegura,
    String? lesion,
    required String? quienAfectado,
    required String? descripcion,
    int? frecuencia,
    int? severidad,
    int? potencial,
    File? imagen,
  }) {
    if (lugar == null || lugar.isEmpty) return "Debe ingresar el lugar del incidente";
    if (quienAfectado == null || quienAfectado.isEmpty) return "Debe seleccionar a quién le ocurrió";
    if (tipoAccidente == null || tipoAccidente.isEmpty) return "Debe seleccionar el tipo de accidente";

    if (tipoAccidente != "Cuasi Accidente") {
      if (lesion == null || lesion.isEmpty) return "Debe seleccionar el tipo de lesión";
    }

    if (actividad == null || actividad.isEmpty) return "Debe seleccionar la actividad";

    if (clasificacion == null || clasificacion.isEmpty) {
      return "Debe seleccionar la clasificación";
    }

    if (clasificacion == "Acción Insegura" && (accionInsegura == null || accionInsegura.isEmpty)) {
      return "Debe seleccionar la acción insegura";
    }

    if (clasificacion == "Condición Insegura" && (condicionInsegura == null || condicionInsegura.isEmpty)) {
      return "Debe seleccionar la condición insegura";
    }

    if (descripcion == null || descripcion.isEmpty) return "Debe ingresar una descripción";

    if (frecuencia != null && severidad != null) {
      if (potencial == null) return "No se pudo calcular el potencial";
    }

    return null;
  }
}