import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/opciones.dart';

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
  final int? potencial; // 🔄 ahora usamos potencial
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
    required this.potencial, // 🔄
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
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "¿A quién le ocurrió?"),
          initialValue: quienAfectado,
          hint: const Text("Seleccione una opción"),
          items: ["Trabajador", "Visita", "Contratista"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onQuienChanged,
          validator: (v) => v == null || v.isEmpty ? "Seleccione una opción" : null,
        ),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Tipo de accidente"),
          initialValue: tipoAccidente,
          hint: const Text("Seleccione un tipo"),
          items: opcionesAccidente
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onTipoAccidenteChanged,
          validator: (v) => v == null || v.isEmpty ? "Seleccione un tipo de accidente" : null,
        ),

        if (tipoAccidente != "Cuasi Accidente")
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: "Tipo de lesión"),
            initialValue: lesion,
            hint: const Text("Seleccione una lesión"),
            items: opcionesLesion
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onLesionChanged,
            validator: (v) => v == null || v.isEmpty ? "Seleccione una lesión" : null,
          ),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Actividad que realizaba"),
          initialValue: actividad,
          hint: const Text("Seleccione una actividad"),
          items: ["Mantención", "Operación", "Transporte"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onActividadChanged,
          validator: (v) => v == null || v.isEmpty ? "Seleccione una actividad" : null,
        ),

        if (cargo?.toLowerCase() == "encargado de prevención de riesgos") ...[
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: "Frecuencia (1-5)"),
            initialValue: frecuencia,
            items: List.generate(5, (i) => i + 1)
                .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                .toList(),
            onChanged: onFrecuenciaChanged,
          ),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: "Severidad (1-5)"),
            initialValue: severidad,
            items: List.generate(5, (i) => i + 1)
                .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                .toList(),
            onChanged: onSeveridadChanged,
          ),
          Text("Potencial: ${potencial ?? '—'}"), // 🔄 cambiado
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