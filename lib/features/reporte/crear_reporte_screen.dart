import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CrearReporteScreen extends StatefulWidget {
  const CrearReporteScreen({super.key});

  @override
  State<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends State<CrearReporteScreen> {
  final _formKey = GlobalKey<FormState>();

  String cargo = "Encargado de prevención de riesgos";
  String? lugar;
  String? tipoAccidente;
  String? lesion;
  String? actividad;
  String? quienAfectado;
  int? frecuencia;
  int? severidad;
  String? descripcion;

  File? _imagen;
  bool _guardando = false;

  LatLng? ubicacion = const LatLng(-36.826, -73.049); // Ejemplo: Talcahuano

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) {
      setState(() => _imagen = File(picked.path));
    }
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    // Simulación de guardado
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _guardando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Reporte guardado con éxito"), backgroundColor: Colors.red),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Reporte")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset("assets/images/logo.png", height: 60)),
              const SizedBox(height: 16),
              Text("Cargo: $cargo", style: const TextStyle(fontWeight: FontWeight.bold)),

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
                onChanged: (v) => lugar = v,
                validator: (v) => v == null || v.isEmpty ? "Ingrese lugar" : null,
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "¿A quién le ocurrió?"),
                items: ["Trabajador", "Visita", "Contratista"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => quienAfectado = v,
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Tipo de accidente"),
                items: ["Accidente", "Cuasi Accidente"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => tipoAccidente = v),
              ),

              if (tipoAccidente != "Cuasi Accidente")
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Tipo de lesión"),
                  items: ["Corte", "Golpe", "Fractura"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => lesion = v,
                ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Actividad que realizaba"),
                items: ["Mantención", "Operación", "Transporte"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => actividad = v,
              ),

              if (cargo.toLowerCase() == "encargado de prevención de riesgos") ...[
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Frecuencia (1-5)"),
                  items: List.generate(5, (i) => i + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                      .toList(),
                  onChanged: (v) => frecuencia = v,
                ),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Severidad (1-5)"),
                  items: List.generate(5, (i) => i + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                      .toList(),
                  onChanged: (v) => severidad = v,
                ),
                Text("Potencial: ${frecuencia != null && severidad != null ? frecuencia! * severidad! : '—'}"),
              ],

              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: "Descripción"),
                maxLines: 3,
                onChanged: (v) => descripcion = v,
              ),

              const SizedBox(height: 16),
              if (_imagen != null)
                Image.file(_imagen!, height: 200, fit: BoxFit.cover),

              ElevatedButton.icon(
                onPressed: _tomarFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Capturar Imagen"),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Finalizar Reporte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}