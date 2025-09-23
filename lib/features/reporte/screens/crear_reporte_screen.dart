import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../reporte/services/perfil_service.dart';
import '../../reporte/services/ubicacion_service.dart';
import '../../reporte/services/validacion_service.dart';
import '../../reporte/services/reporte_service.dart';
import '../../reporte/services/snack_service.dart';
import '../../reporte/services/imagen_service.dart';
import '../../reporte/services/storage_service.dart';

import '../../reporte/widgets/formulario_reporte.dart';

class CrearReporteScreen extends StatefulWidget {
  const CrearReporteScreen({super.key});

  @override
  State<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends State<CrearReporteScreen> {
  String? _rol, _cargo;
  String? _lugar, _tipoAccidente, _actividad, _quienAfectado, _descripcion;
  String? _clasificacion, _potencialAuto;
  List<String> _lesiones = [];
  List<String> _accionesInseguras = [];
  List<String> _condicionesInseguras = [];
  List<String> _medidas = [];
  int? _frecuencia, _severidad;
  File? _imagen;
  LatLng? _ubicacion;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
    _obtenerUbicacion();
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

  void _calcularPotencial() {
    if (_frecuencia != null && _severidad != null) {
      final producto = _frecuencia! * _severidad!;
      _potencialAuto = producto > 6 ? 'Alto' : 'Bajo';
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
    if (rol == null || cargo == null || ubicacion == null) {
      return SnackService.mostrar(
        context,
        'No se pudo obtener perfil o ubicación',
      );
    }

    final error = ValidacionService.validarReporte(
      lugar: _lugar,
      tipoAccidente: _tipoAccidente,
      lesiones: _lesiones,
      actividad: _actividad,
      clasificacion: _clasificacion,
      accionesInseguras: _accionesInseguras,
      condicionesInseguras: _condicionesInseguras,
      medidas: _medidas,
      quienAfectado: _quienAfectado,
      descripcion: _descripcion,
      frecuencia: _frecuencia,
      severidad: _severidad,
      rol: rol,
      cargo: cargo,
      imagen: _imagen,
    );
    if (error != null) return SnackService.mostrar(context, error);

    setState(() => _guardando = true);
    try {
      final urlImagen = _imagen != null
          ? await StorageService.uploadFile(
              file: _imagen!,
              path: 'reportes/${DateTime.now().millisecondsSinceEpoch}.jpg',
            )
          : null;

      await ReporteService.guardar(
        cargo: cargo,
        rol: rol,
        lugar: _lugar!,
        tipoAccidente: _tipoAccidente!,
        lesiones: _lesiones,
        actividad: _actividad!,
        clasificacion: _clasificacion,
        accionesInseguras: _accionesInseguras,
        condicionesInseguras: _condicionesInseguras,
        medidas: _medidas,
        quienAfectado: _quienAfectado!,
        descripcion: _descripcion!,
        frecuencia: _frecuencia,
        severidad: _severidad,
        nivelPotencial: _potencialAuto,
        ubicacion: ubicacion,
        urlImagen: urlImagen,
      );

      if (!mounted) return;
      SnackService.mostrar(
        context,
        'Reporte guardado con éxito',
        success: true,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        SnackService.mostrar(context, 'Error al guardar: $e');
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear reporte'),
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
        child: FormularioReporte(
          cargo: _cargo,
          rol: _rol,
          lugar: _lugar,
          tipoAccidente: _tipoAccidente,
          lesionesSeleccionadas: _lesiones,
          actividad: _actividad,
          clasificacion: _clasificacion,
          accionesInsegurasSeleccionadas: _accionesInseguras,
          condicionesInsegurasSeleccionadas: _condicionesInseguras,
          medidasSeleccionadas: _medidas,
          quienAfectado: _quienAfectado,
          descripcion: _descripcion,
          frecuencia: _frecuencia,
          severidad: _severidad,
          potencialAuto: _potencialAuto,
          imagen: _imagen,
          ubicacion: _ubicacion,
          guardando: _guardando,
          onTomarFoto: _tomarFoto,
          onGuardar: _guardar,
          onLugarChanged: (v) => setState(() => _lugar = v),
          onTipoAccidenteChanged: (v) => setState(() => _tipoAccidente = v),
          onLesionesChanged: (v) => setState(() => _lesiones = v),
          onActividadChanged: (v) => setState(() => _actividad = v),
          onClasificacionChanged: (v) => setState(() => _clasificacion = v),
          onAccionesInsegurasChanged: (v) =>
              setState(() => _accionesInseguras = v),
          onCondicionesInsegurasChanged: (v) =>
              setState(() => _condicionesInseguras = v),
          onMedidasChanged: (v) => setState(() => _medidas = v),
          onQuienChanged: (v) => setState(() => _quienAfectado = v),
          onDescripcionChanged: (v) => setState(() => _descripcion = v),
          onFrecuenciaChanged: (v) {
            _frecuencia = v;
            _calcularPotencial();
          },
          onSeveridadChanged: (v) {
            _severidad = v;
            _calcularPotencial();
          },
        ),
      ),
    );
  }
}
