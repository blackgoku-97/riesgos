import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/opciones.dart';
import 'frecuencia_severidad_fields.dart';
import 'selector_dropdown.dart';

class FormularioReporte extends StatelessWidget {
  final String? cargo;
  final String? rol;
  final String? lugar;
  final String? tipoAccidente;
  final String? lesion;
  final String? actividad;
  final String? quienAfectado;
  final String? descripcion;
  final int? frecuencia;
  final int? severidad;
  final int? potencial;
  final String? nivelPotencial;
  final File? imagen;
  final LatLng? ubicacion;
  final bool guardando;

  final VoidCallback onTomarFoto;
  final VoidCallback onGuardar;

  final ValueChanged<String?> onLugarChanged;
  final ValueChanged<String?> onTipoAccidenteChanged;
  final ValueChanged<String?> onLesionChanged;
  final ValueChanged<String?> onActividadChanged;
  final ValueChanged<String?> onQuienChanged;
  final ValueChanged<String?> onDescripcionChanged;
  final ValueChanged<int?> onFrecuenciaChanged;
  final ValueChanged<int?> onSeveridadChanged;

  const FormularioReporte({
    super.key,
    required this.cargo,
    required this.rol,
    required this.lugar,
    required this.tipoAccidente,
    required this.lesion,
    required this.actividad,
    required this.quienAfectado,
    required this.descripcion,
    required this.frecuencia,
    required this.severidad,
    required this.potencial,
    required this.nivelPotencial,
    required this.imagen,
    required this.ubicacion,
    required this.guardando,
    required this.onTomarFoto,
    required this.onGuardar,
    required this.onLugarChanged,
    required this.onTipoAccidenteChanged,
    required this.onLesionChanged,
    required this.onActividadChanged,
    required this.onQuienChanged,
    required this.onDescripcionChanged,
    required this.onFrecuenciaChanged,
    required this.onSeveridadChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Center(child: Image.asset("assets/images/logo.png", height: 60)),
        const SizedBox(height: 16),
        Text("Cargo: ${cargo ?? '—'}",
            style: const TextStyle(fontWeight: FontWeight.bold)),

        const SizedBox(height: 16),
        if (ubicacion != null)
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: ubicacion!, zoom: 17),
              markers: {
                Marker(markerId: const MarkerId("ubicacion"), position: ubicacion!)
              },
            ),
          ),

        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: "Lugar del incidente"),
          initialValue: lugar,
          onChanged: onLugarChanged,
          validator: (v) => v == null || v.isEmpty ? "Ingrese lugar" : null,
        ),

        const SizedBox(height: 16),
        SelectorDropdown<String>(
          label: "¿A quién le ocurrió?",
          value: quienAfectado,
          opciones: const ["Trabajador", "Visita", "Contratista"],
          getLabel: (o) => o,
          onChanged: onQuienChanged,
        ),

        SelectorDropdown<String>(
          label: "Tipo de accidente",
          value: tipoAccidente,
          opciones: opcionesAccidente,
          getLabel: (o) => o,
          onChanged: onTipoAccidenteChanged,
        ),

        if (tipoAccidente != "Cuasi Accidente")
          SelectorDropdown<String>(
            label: "Tipo de lesión",
            value: lesion,
            opciones: opcionesLesion,
            getLabel: (o) => o,
            onChanged: onLesionChanged,
          ),

        SelectorDropdown<String>(
          label: "Actividad que realizaba",
          value: actividad,
          opciones: opcionesActividad,
          getLabel: (o) => o,
          onChanged: onActividadChanged,
        ),

        if (cargo?.toLowerCase() == "encargado de prevención de riesgos") ...[
          FrecuenciaSeveridadFields(
            frecuencia: frecuencia,
            severidad: severidad,
            nivelPotencial: nivelPotencial,
            onFrecuenciaChanged: onFrecuenciaChanged,
            onSeveridadChanged: onSeveridadChanged,
          ),
        ],

        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: "Descripción"),
          initialValue: descripcion,
          maxLines: 3,
          onChanged: onDescripcionChanged,
          validator: (v) => v == null || v.isEmpty ? "Ingrese una descripción" : null,
        ),

        const SizedBox(height: 16),
        if (imagen != null)
          Image.file(imagen!, height: 200, fit: BoxFit.cover),

        ElevatedButton.icon(
          onPressed: onTomarFoto,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Capturar Imagen"),
        ),

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: guardando ? null : onGuardar,
          child: guardando
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Finalizar Reporte"),
        ),
      ],
    );
  }
}