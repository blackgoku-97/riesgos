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
  final String? cargo, rol, riesgoAuto;
  final TextEditingController planTrabajoCtrl;
  final String? areaSel, procesoSel, actividadSel;
  final List<String> peligrosSel, agenteSel, medidasSel;
  final int? frecuencia, severidad;
  final File? imagen;
  final LatLng? ubicacion;
  final bool guardando;
  final VoidCallback onTomarFoto, onGuardar;
  final ValueChanged<String?> onAreaChanged, onProcesoChanged, onActividadChanged;
  final ValueChanged<List<String>> onPeligrosChanged, onAgenteChanged, onMedidasChanged;
  final ValueChanged<int?> onFrecuenciaChanged, onSeveridadChanged;

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
    final espacio8 = const SizedBox(height: 8);
    final espacio12 = const SizedBox(height: 12);
    final espacio16 = const SizedBox(height: 16);

    final areaEnum = opcionesArea.firstWhere(
      (a) => a.label == areaSel,
      orElse: () => Area.seleccionar,
    );

    return ListView(
      children: [
        const Text("Datos del trabajador",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        espacio12,
        Text("Cargo: ${cargo ?? '—'}"),
        espacio12,

        TextFormField(
          controller: planTrabajoCtrl,
          decoration: const InputDecoration(
            labelText: 'Plan de trabajo',
            border: OutlineInputBorder(),
          ),
        ),
        espacio12,

        // Área
        SelectorDropdown<String>(
          label: 'Área',
          value: (areaSel != null &&
                  opcionesArea.map((a) => a.label).contains(areaSel))
              ? areaSel
              : null,
          opciones: opcionesArea.map((a) => a.label).toList(),
          getLabel: (v) => v,
          onChanged: onAreaChanged,
        ),

        // Proceso
        if (opcionesProceso[areaEnum]!.isNotEmpty) ...[
          espacio12,
          SelectorDropdown<String>(
            label: 'Proceso',
            value: (procesoSel != null &&
                    opcionesProceso[areaEnum]!.contains(procesoSel))
                ? procesoSel
                : null,
            opciones: opcionesProceso[areaEnum]!,
            getLabel: (v) => v,
            onChanged: onProcesoChanged,
          ),
        ],

        // Actividad
        if (opcionesActividad[areaEnum]!.isNotEmpty) ...[
          espacio12,
          SelectorDropdown<String>(
            label: 'Actividad',
            value: (actividadSel != null &&
                    opcionesActividad[areaEnum]!.contains(actividadSel))
                ? actividadSel
                : null,
            opciones: opcionesActividad[areaEnum]!,
            getLabel: (v) => v,
            onChanged: onActividadChanged,
          ),
        ],

        // Peligros
        if (opcionesPeligro[areaEnum]!.isNotEmpty) ...[
          espacio12,
          SelectorPeligros(
            label: 'Peligros',
            opciones: opcionesPeligro[areaEnum]!,
            seleccionados: peligrosSel,
            onChanged: onPeligrosChanged,
          ),
        ],

        // Agente material
        if (opcionesAgenteMaterial[areaEnum]!.isNotEmpty) ...[
          espacio12,
          SelectorPeligros(
            label: 'Agente material',
            opciones: opcionesAgenteMaterial[areaEnum]!,
            seleccionados: agenteSel,
            onChanged: onAgenteChanged,
          ),
        ],

        espacio12,
        SelectorPeligros(
          label: 'Medidas',
          opciones: opcionesMedidas,
          seleccionados: medidasSel,
          onChanged: onMedidasChanged,
        ),

        // Solo admin puede ver frecuencia/severidad
        if (rol == 'admin') ...[
          espacio12,
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
        espacio12,

        if (imagen != null) Image.file(imagen!, height: 160, fit: BoxFit.cover),
        OutlinedButton.icon(
          onPressed: onTomarFoto,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Tomar foto'),
        ),

        espacio16,
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