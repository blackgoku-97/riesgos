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

class CrearPlanificacionScreen extends StatefulWidget {
  const CrearPlanificacionScreen({super.key});

  @override
  State<CrearPlanificacionScreen> createState() => _CrearPlanificacionScreenState();
}

class _CrearPlanificacionScreenState extends State<CrearPlanificacionScreen> {
  final _planTrabajoCtrl = TextEditingController();
  String? _areaSel, _procesoSel, _actividadSel, _rol, _riesgoAuto;
  final _peligrosSel = <String>[];
  final _agenteSel = <String>[];
  final _medidasSel = <String>[];
  int? _frecuencia, _severidad;
  File? _imagen;
  LatLng? _ubicacion;
  bool _guardando = false;

  final espacio = const SizedBox(height: 12);

  @override
  void initState() {
    super.initState();
    _cargarRol();
    _obtenerUbicacion();
  }

  Future<void> _cargarRol() async {
    final rol = await PerfilService.obtenerRolUsuario();
    if (mounted) setState(() => _rol = rol);
  }

  Future<void> _obtenerUbicacion() async {
    final ubic = await UbicacionService.obtenerUbicacion(context);
    if (mounted && ubic != null) setState(() => _ubicacion = ubic);
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
    if (mounted && img != null) setState(() => _imagen = img);
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
      imagen: _imagen,
    );
    if (error != null) return SnackService.mostrar(context, error);

    setState(() => _guardando = true);
    try {
      String? urlImagen;
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
      SnackService.mostrar(context, 'Planificación guardada con éxito', success: true);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        SnackService.mostrar(context, 'Error al guardar: $e');
        setState(() => _guardando = false);
      }
    }
  }

  Widget _buildDropdown(String label, String? value, List<String> opciones, ValueChanged<String?> onChanged) {
    if (opciones.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        espacio,
        SelectorDropdown<String>(
          label: label,
          value: value,
          opciones: opciones,
          getLabel: (v) => v,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPeligros(String label, List<String> opciones, List<String> seleccionados, ValueChanged<List<String>> onChanged) {
    if (opciones.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        espacio,
        SelectorPeligros(
          label: label,
          opciones: opciones,
          seleccionados: seleccionados,
          onChanged: (sel) => setState(() {
            seleccionados
              ..clear()
              ..addAll(sel);
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final areaEnum = opcionesArea.firstWhere(
      (a) => a.label == _areaSel,
      orElse: () => Area.seleccionar,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear planificación'),
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
            espacio,
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
            _buildDropdown('Proceso', _procesoSel, opcionesProceso[areaEnum]!, (v) => setState(() => _procesoSel = v)),
            _buildDropdown('Actividad', _actividadSel, opcionesActividad[areaEnum]!, (v) => setState(() => _actividadSel = v)),
            _buildPeligros('Peligros', opcionesPeligro[areaEnum]!, _peligrosSel, (_) {}),
            _buildPeligros('Agente material', opcionesAgenteMaterial[areaEnum]!, _agenteSel, (_) {}),
            espacio,
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
              espacio,
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
            espacio,
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
              text: 'Guardar',
              color: Theme.of(context).colorScheme.primary,
              onPressed: _guardando ? () {} : _guardar,
            ),
          ],
        ),
      ),
    );
  }
}