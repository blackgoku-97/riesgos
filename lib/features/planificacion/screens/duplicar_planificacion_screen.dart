import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/validacion_service.dart';
import '../services/planificacion_service.dart';
import '../services/perfil_service.dart';
import '../services/ubicacion_service.dart';
import '../services/snack_service.dart';
import '../services/imagen_service.dart';
import '../services/storage_service.dart';

import '../widgets/formulario_planificacion.dart';

class DuplicarPlanificacionScreen extends StatefulWidget {
  final Map<String, dynamic> planificacion;

  const DuplicarPlanificacionScreen({
    super.key,
    required this.planificacion,
  });

  @override
  State<DuplicarPlanificacionScreen> createState() =>
      _DuplicarPlanificacionScreenState();
}

class _DuplicarPlanificacionScreenState
    extends State<DuplicarPlanificacionScreen> {
  late TextEditingController _planTrabajoCtrl;
  String? _areaSel, _procesoSel, _actividadSel, _rol, _cargo, _riesgoAuto;
  List<String> _peligrosSel = [];
  List<String> _agenteSel = [];
  List<String> _medidasSel = [];
  int? _frecuencia, _severidad;
  File? _imagen;
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

    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final perfil = await PerfilService.obtenerPerfilUsuario();
    if (!mounted) return;
    setState(() {
      _rol = (perfil?['rol'] as String?)?.trim().toLowerCase();
      _cargo = (perfil?['cargo'] as String?)?.trim();
    });
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
    final cargo = _cargo;
    final rol = _rol;
    final ubicacion = _ubicacion;

    if (rol == null || ubicacion == null || cargo == null) {
      return SnackService.mostrar(
        context,
        'No se pudo obtener el rol, cargo o la ubicación',
      );
    }

    final error = ValidacionService.validar(
      plan: _planTrabajoCtrl.text,
      area: _areaSel,
      proceso: _procesoSel,
      actividad: _actividadSel,
      peligros: _peligrosSel,
      agenteMaterial: _agenteSel,
      medidas: _medidasSel,
      ubicacion: ubicacion,
      rol: rol,
      cargo: cargo,
      frecuencia: _frecuencia,
      severidad: _severidad,
      imagen: _imagen,
    );

    if (error != null) return SnackService.mostrar(context, error);

    setState(() => _guardando = true);

    try {
      String? urlImagen = widget.planificacion['urlImagen'];

      if (_imagen != null) {
        urlImagen = await StorageService.uploadFile(
          file: _imagen!,
          path: 'planificaciones/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      await PlanificacionService.guardar(
        cargo: cargo,
        rol: rol,
        planTrabajo: _planTrabajoCtrl.text.trim(),
        area: _areaSel!,
        proceso: _procesoSel,
        actividad: _actividadSel,
        peligros: _peligrosSel,
        agenteMaterial: _agenteSel,
        medidas: _medidasSel,
        ubicacion: ubicacion,
        frecuencia: _frecuencia,
        severidad: _severidad,
        nivelRiesgo: _riesgoAuto,
        urlImagen: urlImagen,
      );

      if (!mounted) return;
      SnackService.mostrar(
        context,
        'Planificación duplicada con éxito',
        success: true,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        SnackService.mostrar(context, 'Error al duplicar: $e');
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: FormularioPlanificacion(
          cargo: _cargo,
          rol: _rol,
          planTrabajoCtrl: _planTrabajoCtrl,
          areaSel: _areaSel,
          procesoSel: _procesoSel,
          actividadSel: _actividadSel,
          peligrosSel: _peligrosSel,
          agenteSel: _agenteSel,
          medidasSel: _medidasSel,
          frecuencia: _frecuencia,
          severidad: _severidad,
          riesgoAuto: _riesgoAuto,
          imagen: _imagen,
          ubicacion: _ubicacion,
          guardando: _guardando,
          onTomarFoto: _tomarFoto,
          onGuardar: _guardar,
          onAreaChanged: (v) {
            setState(() {
              _areaSel = v;
              _procesoSel = null;
              _actividadSel = null;
              _peligrosSel = [];
              _agenteSel = [];
              _medidasSel = [];
            });
          },
          onProcesoChanged: (v) => setState(() => _procesoSel = v),
          onActividadChanged: (v) => setState(() => _actividadSel = v),
          onPeligrosChanged: (sel) =>
              setState(() => _peligrosSel = List.from(sel)),
          onAgenteChanged: (sel) =>
              setState(() => _agenteSel = List.from(sel)),
          onMedidasChanged: (sel) =>
              setState(() => _medidasSel = List.from(sel)),
          onFrecuenciaChanged: (v) {
            _frecuencia = v;
            _calcularRiesgo();
          },
          onSeveridadChanged: (v) {
            _severidad = v;
            _calcularRiesgo();
          },
        ),
      ),
    );
  }
}