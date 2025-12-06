import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaUbicacion extends StatelessWidget {
  final LatLng? ubicacion;

  const MapaUbicacion({super.key, required this.ubicacion});

  @override
  Widget build(BuildContext context) {
    if (ubicacion == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: ubicacion!,
          zoom: 17,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('ubicacion'),
            position: ubicacion!,
            infoWindow: const InfoWindow(title: 'Ubicación actual'),
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}