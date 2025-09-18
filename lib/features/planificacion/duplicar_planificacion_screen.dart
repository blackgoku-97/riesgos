import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../planificacion/services/validacion_service.dart';
import '../planificacion/services/planificacion_service.dart';
import '../planificacion/services/perfil_service.dart';
import '../planificacion/services/ubicacion_service.dart';
import '../planificacion/services/snack_service.dart';
import '../planificacion/services/imagen_service.dart';
import '../planificacion/services/storage_service.dart';

import '../planificacion/constants/opciones_area.dart';

import '../planificacion/widgets/selector_dropdown.dart';
import '../planificacion/widgets/selector_peligros.dart';
import '../planificacion/widgets/frecuencia_severidad_fields.dart';
import '../planificacion/widgets/mapa_ubicacion.dart';
import '../planificacion/widgets/guardar_button.dart';

class DuplicarPlanificacionScreen extends StatefulWidget {
  final Map<String, dynamic> planificacion;

  const DuplicarPlanificacionScreen({super.key, required this.planificacion, required data, required origenId});

  @override
  State<DuplicarPlanificacionScreen> createState() => _DuplicarPlanificacionScreenState();
}

class _DuplicarPlanificacionScreenState extends State<DuplicarPlanificacionScreen> {
  late TextEditingController _planTrabajoCtrl;
  String? _areaSel;
  String? _procesoSel;
  String? _actividadSel;
  late List<String> _peligrosSel;
  late List<String> _agenteSel;
  late List<String> _medidasSel;
  int? _frecuencia;
  int? _severidad;
  String? _riesgoAuto;
  File? _imagen;
  String? _rol;
  LatLng? _ubicacion;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.planificacion;
    _planTrabajoCtrl = TextEditingController(text: p['planTrabajo'] ?? '');
    _areaSel = p['area'];
    _procesoSel = p['proceso'];
    _actividadSel = p['actividad'];
    _peligrosSel = List<String>.from(p['peligros'] ?? []);
    _agenteSel = List<String>.from(p['agenteMaterial'] ?? []);
    _medidasSel = List<String>.from(p['medidas'] ?? []);
    _frecuencia = p['frecuencia'];
    _severidad = p['severidad'];
    _riesgoAuto = p['nivelRiesgo'];
    if (p['ubicacion'] != null) {
      final u = p['ubicacion'];
      _ubicacion = LatLng(u.latitude, u.longitude);
    }
    _cargarRol();
    if (_ubicacion == null) _obtenerUbicacion();
  }

  Future<void> _cargarRol() async {
    final rol = await PerfilService.obtenerRolUsuario();
    if (!mounted) return;
    setState(() => _rol = rol);
  }

  Future<void> _obtenerUbicacion() async {
    final ubic = await UbicacionService.obtenerUbicacion(context);
    if (!mounted) return;
    if (ubic != null) setState(() => _ubicacion = ubic);
  }

  void _calcularRiesgo() {
    if (_frecuencia != null && _severidad != null) {
      final producto = _frecuencia! * _severidad!;
      _riesgoAuto = producto > 6 ? 'Aceptable' : 'No Aceptable';
      setState(() {});
    }
  }

  Future<void> _tomarFoto() async {
    final img = await ImagenService.tomarFoto();
    if (!mounted) return;
    if (img != null) setState(() => _imagen = img);
  }

  Future<void> _guardar() async {
    final error = ValidacionService.validar(
      plan: _planTrabajoCtrl.text,
      area: _areaSel,
      proceso: _procesoSel,
      actividad: _actividadSel,
      peligros: _peligrosSel,
      agenteMaterial: _agenteSel,
      medidas: _medidasSel,
      ubicacion: _ubicacion,
      rol: _rol,
      frecuencia: _frecuencia,
      severidad: _severidad,
      imagen: _imagen ?? (widget.planificacion['urlImagen'] != null ? File('') : null),
    );
    if (error != null) {
      SnackService.mostrar(context, error);
      return;
    }
    setState(() => _guardando = true);

    String? urlImagen = widget.planificacion['urlImagen'];
    try {
      if (_imagen != null) {
        final path = 'planificaciones/${DateTime.now().millisecondsSinceEpoch}.jpg';
        urlImagen = await StorageService.uploadFile(file: _imagen!, path: path);
      }
      await PlanificacionService.guardar(
        planTrabajo: _planTrabajoCtrl.text.trim(),
        area: _areaSel!,
        proceso: _procesoSel,
        actividad: _actividadSel,
        peligros: _peligrosSel,
        agenteMaterial: _agenteSel,
        medidas: _medidasSel,
        ubicacion: _ubicacion!,
        frecuencia: _frecuencia,
        severidad: _severidad,
        nivelRiesgo: _riesgoAuto,
        urlImagen: urlImagen,
      );
      if (!mounted) return;
      SnackService.mostrar(context, 'Planificación duplicada con éxito', success: true);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      SnackService.mostrar(context, 'Error al duplicar: $e');
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final areaEnum = opcionesArea.firstWhere(
      (a) => a.label == _areaSel,
      orElse: () => Area.seleccionar,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplicar planificación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _obtenerUbicacion,
            tooltip: 'Actualizar ubicación',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              controller: _planTrabajoCtrl,
              decoration: const InputDecoration(
                labelText: 'Plan de trabajo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SelectorDropdown<String>(
              label: 'Área',
              value: _areaSel,
              opciones: opcionesArea.map((a) => a.label).toList(),
              getLabel: (v) => v,
              onChanged: (v) {
                setState(() {
                  _areaSel = v;
                  _procesoSel = null;
                  _actividadSel = null;
                  _peligrosSel.clear();
                  _agenteSel.clear();
                });
              },
            ),
            if (opcionesProceso[areaEnum]!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SelectorDropdown<String>(
                label: 'Proceso',
                value: _procesoSel,
                opciones: opcionesProceso[areaEnum]!,
                getLabel: (v) => v,
                onChanged: (v) => setState(() => _procesoSel = v),
              ),
            ],
            if (opcionesActividad[areaEnum]!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SelectorDropdown<String>(
                label: 'Actividad',
                value: _actividadSel,
                opciones: opcionesActividad[areaEnum]!,
                getLabel: (v) => v,
                onChanged: (v) => setState(() => _actividadSel = v),
              ),
            ],
            if (opcionesPeligro[areaEnum]!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SelectorPeligros(
                label: 'Peligros',
                opciones: opcionesPeligro[areaEnum]!,
                seleccionados: _peligrosSel,
                onChanged: (sel) => setState(() {
                  _peligrosSel
                    ..clear()
                    ..addAll(sel);
                }),
              ),
            ],
            if (opcionesAgenteMaterial[areaEnum]!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SelectorPeligros(
                label: 'Agente material',
                opciones: opcionesAgenteMaterial[areaEnum]!,
                seleccionados: _agenteSel,
                onChanged: (sel) => setState(() {
                  _agenteSel
                    ..clear()
                    ..addAll(sel);
                }),
              ),
            ],
            const SizedBox(height: 12),
            SelectorPeligros(
              label: 'Medidas',
              opciones: opcionesMedidas,
              seleccionados: _medidasSel,
              onChanged: (sel) => setState(() {
                _medidasSel
                  ..clear()
                  ..addAll(sel);
              }),
            ),
            if (_rol == 'admin') ...[
              const SizedBox(height: 12),
              FrecuenciaSeveridadFields(
                frecuencia: _frecuencia,
                severidad: _severidad,
                nivelRiesgo: _riesgoAuto,
                onFrecuenciaChanged: (v) {
                  _frecuencia = v;
                  _calcularRiesgo();
                },
                onSeveridadChanged: (v) {
                  _severidad = v;
                  _calcularRiesgo();
                },
              ),
            ],
            const SizedBox(height: 8),
            MapaUbicacion(ubicacion: _ubicacion),
            const SizedBox(height: 12),
            if (_imagen != null)
              Image.file(_imagen!, height: 160, fit: BoxFit.cover),
            OutlinedButton.icon(
              onPressed: _tomarFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar foto'),
            ),
            const SizedBox(height: 16),
            GuardarButton(
              loading: _guardando,
              text: 'Duplicar',
              color: Theme.of(context).colorScheme.primary,
              onPressed: _guardando ? () {} : _guardar,
            ),
          ],
        ),
      ),
    );
  }
}