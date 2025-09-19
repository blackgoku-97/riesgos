import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/opciones_area.dart';
import 'selector_dropdown.dart';
import 'selector_peligros.dart';
import 'frecuencia_severidad_fields.dart';
import 'mapa_ubicacion.dart';
import 'guardar_button.dart';

class FormularioPlanificacion extends StatelessWidget {
  final String? cargo;
  final String? rol;
  final TextEditingController planTrabajoCtrl;
  final String? areaSel;
  final String? procesoSel;
  final String? actividadSel;
  final List<String> peligrosSel;
  final List<String> agenteSel;
  final List<String> medidasSel;
  final int? frecuencia;
  final int? severidad;
  final String? riesgoAuto;
  final File? imagen;
  final LatLng? ubicacion;
  final bool guardando;
  final VoidCallback onTomarFoto;
  final VoidCallback onGuardar;
  final ValueChanged<String?> onAreaChanged;
  final ValueChanged<String?> onProcesoChanged;
  final ValueChanged<String?> onActividadChanged;
  final ValueChanged<List<String>> onPeligrosChanged;
  final ValueChanged<List<String>> onAgenteChanged;
  final ValueChanged<List<String>> onMedidasChanged;
  final ValueChanged<int?> onFrecuenciaChanged;
  final ValueChanged<int?> onSeveridadChanged;

  const FormularioPlanificacion({
    super.key,
    required this.cargo,
    required this.rol,
    required this.planTrabajoCtrl,
    required this.areaSel,
    required this.procesoSel,
    required this.actividadSel,
    required this.peligrosSel,
    required this.agenteSel,
    required this.medidasSel,
    required this.frecuencia,
    required this.severidad,
    required this.riesgoAuto,
    required this.imagen,
    required this.ubicacion,
    required this.guardando,
    required this.onTomarFoto,
    required this.onGuardar,
    required this.onAreaChanged,
    required this.onProcesoChanged,
    required this.onActividadChanged,
    required this.onPeligrosChanged,
    required this.onAgenteChanged,
    required this.onMedidasChanged,
    required this.onFrecuenciaChanged,
    required this.onSeveridadChanged,
  });

  @override
  Widget build(BuildContext context) {
    final espacio = const SizedBox(height: 12);
    final espacio8 = const SizedBox(height: 8);

    final areaEnum = opcionesArea.firstWhere(
      (a) => a.label == areaSel,
      orElse: () => Area.seleccionar,
    );

    return ListView(
      children: [
        TextFormField(
          initialValue: cargo ?? '',
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Cargo',
            border: OutlineInputBorder(),
          ),
        ),
        espacio,
        TextFormField(
          controller: planTrabajoCtrl,
          decoration: const InputDecoration(
            labelText: 'Plan de trabajo',
            border: OutlineInputBorder(),
          ),
        ),
        espacio,
        SelectorDropdown<String>(
          label: 'Área',
          value: areaSel,
          opciones: opcionesArea.map((a) => a.label).toList(),
          getLabel: (v) => v,
          onChanged: onAreaChanged,
        ),
        if (opcionesProceso[areaEnum]!.isNotEmpty) ...[
          espacio,
          SelectorDropdown<String>(
            label: 'Proceso',
            value: procesoSel,
            opciones: opcionesProceso[areaEnum]!,
            getLabel: (v) => v,
            onChanged: onProcesoChanged,
          ),
        ],
        if (opcionesActividad[areaEnum]!.isNotEmpty) ...[
          espacio,
          SelectorDropdown<String>(
            label: 'Actividad',
            value: actividadSel,
            opciones: opcionesActividad[areaEnum]!,
            getLabel: (v) => v,
            onChanged: onActividadChanged,
          ),
        ],
        if (opcionesPeligro[areaEnum]!.isNotEmpty) ...[
          espacio,
          SelectorPeligros(
            label: 'Peligros',
            opciones: opcionesPeligro[areaEnum]!,
            seleccionados: peligrosSel,
            onChanged: onPeligrosChanged,
          ),
        ],
        if (opcionesAgenteMaterial[areaEnum]!.isNotEmpty) ...[
          espacio,
          SelectorPeligros(
            label: 'Agente material',
            opciones: opcionesAgenteMaterial[areaEnum]!,
            seleccionados: agenteSel,
            onChanged: onAgenteChanged,
          ),
        ],
        espacio,
        SelectorPeligros(
          label: 'Medidas',
          opciones: opcionesMedidas,
          seleccionados: medidasSel,
          onChanged: onMedidasChanged,
        ),
        if (rol == 'admin') ...[
          espacio,
          FrecuenciaSeveridadFields(
            frecuencia: frecuencia,
            severidad: severidad,
            nivelRiesgo: riesgoAuto,
            onFrecuenciaChanged: onFrecuenciaChanged,
            onSeveridadChanged: onSeveridadChanged,
          ),
        ],
        espacio8,
        MapaUbicacion(ubicacion: ubicacion),
        espacio,
        if (imagen != null) Image.file(imagen!, height: 160, fit: BoxFit.cover),
        OutlinedButton.icon(
          onPressed: onTomarFoto,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Tomar foto'),
        ),
        const SizedBox(height: 16),
        GuardarButton(
          loading: guardando,
          text: 'Guardar',
          color: Theme.of(context).colorScheme.primary,
          onPressed: guardando ? () {} : onGuardar,
        ),
      ],
    );
  }
}