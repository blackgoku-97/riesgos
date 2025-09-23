import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/opciones.dart';
import 'frecuencia_severidad_fields.dart';
import 'selector_dropdown.dart';
import 'selector_lesiones.dart';
import 'selector_clasificaciones.dart';
import 'selector_medidas.dart';
import 'mapa_ubicacion.dart';
import 'guardar_button.dart';

class FormularioReporte extends StatelessWidget {
  final String? cargo, rol, lugar, tipoAccidente;
  final List<String> lesionesSeleccionadas, accionesInsegurasSeleccionadas, condicionesInsegurasSeleccionadas, medidasSeleccionadas;
  final String? actividad, clasificacion, quienAfectado, descripcion, potencialAuto;
  final int? frecuencia, severidad;
  final File? imagen;
  final LatLng? ubicacion;
  final bool guardando;

  final VoidCallback onTomarFoto, onGuardar;

  final ValueChanged<String?> onLugarChanged, onTipoAccidenteChanged;
  final ValueChanged<List<String>> onLesionesChanged, onAccionesInsegurasChanged, onCondicionesInsegurasChanged, onMedidasChanged;
  final ValueChanged<String?> onActividadChanged, onClasificacionChanged;
  final ValueChanged<String?> onQuienChanged, onDescripcionChanged;
  final ValueChanged<int?> onFrecuenciaChanged, onSeveridadChanged;

  const FormularioReporte({
    super.key,
    required this.cargo,
    required this.rol,
    required this.lugar,
    required this.tipoAccidente,
    required this.lesionesSeleccionadas,
    required this.actividad,
    required this.clasificacion,
    required this.accionesInsegurasSeleccionadas,
    required this.condicionesInsegurasSeleccionadas,
    required this.medidasSeleccionadas,
    required this.quienAfectado,
    required this.descripcion,
    required this.frecuencia,
    required this.severidad,
    required this.potencialAuto,
    required this.imagen,
    required this.ubicacion,
    required this.guardando,
    required this.onTomarFoto,
    required this.onGuardar,
    required this.onLugarChanged,
    required this.onTipoAccidenteChanged,
    required this.onLesionesChanged,
    required this.onActividadChanged,
    required this.onClasificacionChanged,
    required this.onAccionesInsegurasChanged,
    required this.onCondicionesInsegurasChanged,
    required this.onMedidasChanged,
    required this.onQuienChanged,
    required this.onDescripcionChanged,
    required this.onFrecuenciaChanged,
    required this.onSeveridadChanged,
  });

  @override
  Widget build(BuildContext context) {
    final espacio12 = const SizedBox(height: 12);
    final espacio20 = const SizedBox(height: 20);
    final espacio24 = const SizedBox(height: 24);
    final espacio32 = const SizedBox(height: 32);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: Image.asset("assets/images/logo.png", height: 60)),
        espacio24,

        const Text("Datos del trabajador",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        espacio12,
        Text("Cargo: ${cargo ?? '—'}"),
        espacio24,

        const Text("Ubicación",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        espacio12,
        MapaUbicacion(ubicacion: ubicacion),
        espacio24,

        const Text("Detalles del incidente",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        espacio12,
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Lugar del incidente",
            border: OutlineInputBorder(),
          ),
          initialValue: lugar,
          onChanged: onLugarChanged,
          validator: (v) => v == null || v.isEmpty ? "Ingrese lugar" : null,
        ),
        espacio20,

        SelectorDropdown<String>(
          label: "¿A quién le ocurrió?",
          value: quienAfectado,
          opciones: opcionesAQuienOcurrio,
          getLabel: (o) => o,
          onChanged: onQuienChanged,
        ),
        espacio20,

        SelectorDropdown<String>(
          label: "Tipo de accidente",
          value: tipoAccidente,
          opciones: opcionesAccidente,
          getLabel: (o) => o,
          onChanged: onTipoAccidenteChanged,
        ),
        espacio20,

        if (tipoAccidente != "Cuasi Accidente")
          SelectorLesiones(
            opciones: opcionesLesion,
            seleccionadas: lesionesSeleccionadas,
            onChanged: onLesionesChanged,
          ),
        if (tipoAccidente != "Cuasi Accidente") espacio20,

        SelectorDropdown<String>(
          label: "Actividad que realizaba",
          value: actividad,
          opciones: opcionesActividad,
          getLabel: (o) => o,
          onChanged: onActividadChanged,
        ),
        espacio20,

        SelectorDropdown<String>(
          label: "Clasificación",
          value: clasificacion,
          opciones: opcionesClasificacion,
          getLabel: (o) => o,
          onChanged: onClasificacionChanged,
        ),
        espacio20,

        if (clasificacion == "Acción Insegura")
          SelectorClasificaciones(
            label: "Acciones Inseguras",
            opciones: accionesInseguras,
            seleccionados: accionesInsegurasSeleccionadas,
            onChanged: onAccionesInsegurasChanged,
          ),

        if (clasificacion == "Condición Insegura")
          SelectorClasificaciones(
            label: "Condiciones Inseguras",
            opciones: condicionesInseguras,
            seleccionados: condicionesInsegurasSeleccionadas,
            onChanged: onCondicionesInsegurasChanged,
          ),

        espacio24,

        SelectorMedidas(
          opciones: opcionesMedidas,
          seleccionadas: medidasSeleccionadas,
          onChanged: onMedidasChanged,
        ),
        espacio24,

        // Solo admin puede ver frecuencia/severidad
        if (rol == 'admin') ...[
          espacio12,
          FrecuenciaSeveridadFields(
            frecuencia: frecuencia,
            severidad: severidad,
            nivelPotencial: potencialAuto,
            onFrecuenciaChanged: onFrecuenciaChanged,
            onSeveridadChanged: onSeveridadChanged,
          ),
        ],

        const Text("Descripción",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        espacio12,
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Descripción",
            border: OutlineInputBorder(),
          ),
          initialValue: descripcion,
          maxLines: 3,
          onChanged: onDescripcionChanged,
          validator: (v) =>
              v == null || v.isEmpty ? "Ingrese una descripción" : null,
        ),
        espacio24,

        const Text("Evidencia fotográfica",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        espacio12,
        if (imagen != null)
          Image.file(imagen!, height: 200, fit: BoxFit.cover),
        ElevatedButton.icon(
          onPressed: onTomarFoto,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Capturar Imagen"),
        ),
        espacio32,

        GuardarButton(
          loading: guardando,
          text: 'Finalizar Reporte',
          color: Theme.of(context).colorScheme.primary,
          onPressed: onGuardar,
        ),
      ],
    );
  }
}