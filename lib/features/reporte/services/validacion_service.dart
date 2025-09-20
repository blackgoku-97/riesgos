import 'dart:io';

class ValidacionService {
  static String? validarReporte({
    String? lugar,
    String? tipoAccidente,
    String? lesion,
    String? actividad,
    String? quienAfectado,
    String? descripcion,
    int? frecuencia,
    int? severidad,
    int? potencial, // 🔄 validamos potencial
    File? imagen,
  }) {
    if (lugar == null || lugar.isEmpty) {
      return "Debe ingresar el lugar del incidente";
    }
    if (tipoAccidente == null || tipoAccidente.isEmpty) {
      return "Debe seleccionar el tipo de accidente";
    }
    if (tipoAccidente != "Cuasi Accidente" &&
        (lesion == null || lesion.isEmpty)) {
      return "Debe seleccionar el tipo de lesión";
    }
    if (actividad == null || actividad.isEmpty) {
      return "Debe seleccionar la actividad";
    }
    if (quienAfectado == null || quienAfectado.isEmpty) {
      return "Debe indicar a quién le ocurrió";
    }
    if (descripcion == null || descripcion.isEmpty) {
      return "Debe ingresar una descripción";
    }

    // Si es encargado de prevención, frecuencia y severidad son obligatorias
    if (frecuencia == null || severidad == null) {
      return "Debe ingresar frecuencia y severidad";
    }

    // Potencial se calcula como frecuencia * severidad
    if (potencial == null) {
      return "No se pudo calcular el potencial";
    }

    return null; // ✅ Todo válido
  }
}