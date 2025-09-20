import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UbicacionService {
  static Future<LatLng?> obtenerUbicacion(BuildContext context) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _mostrarSnackBar(context, 'Activa los servicios de ubicación');
      }
      return null;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied) {
      if (context.mounted) {
        _mostrarSnackBar(context, 'Permiso de ubicación denegado');
      }
      return null;
    }
    if (permiso == LocationPermission.deniedForever) {
      if (context.mounted) {
        _mostrarSnackBar(context, 'Permiso de ubicación denegado permanentemente. Ve a Ajustes.');
      }
      return null;
    }

    final pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }

  static void _mostrarSnackBar(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }
}