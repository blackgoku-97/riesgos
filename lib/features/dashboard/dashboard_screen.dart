import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? rol;
  String nombre = '';
  String cargo = '';
  String genero = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final user = FirebaseAuth.instance.currentUser;

    // Si no hay usuario autenticado → al login
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    // Cargar perfil desde Firestore
    final perfilRef = FirebaseFirestore.instance
        .collection('perfiles')
        .doc(user.uid);
    final perfilSnap = await perfilRef.get();

    if (!perfilSnap.exists) {
      // Si no existe el perfil → cerrar sesión y volver al login
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    final datos = perfilSnap.data()!;
    setState(() {
      rol = (datos['rol'] ?? '').toString();
      nombre = (datos['nombre'] ?? user.email ?? '').toString();
      genero = (datos['genero'] ?? '').toString();
      cargo = (datos['cargo'] ?? '').toString();
      _loading = false;
    });
  }

  String get saludo {
    final g = genero.trim().toLowerCase();
    if (g == 'femenino') return 'Bienvenida';
    if (g == 'masculino') return 'Bienvenido';
    return 'Bienvenido/a';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(
        backgroundColor: AppColors.rojo,
        title: const Text('Centro de Operaciones Preventivas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Logo y saludo
            Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  '$saludo${nombre.isNotEmpty ? ', $nombre' : ''}'
                  '${cargo.trim().isNotEmpty ? ' - $cargo' : ''} 👋',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seleccione una acción a realizar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 32),
              ],
            ),

            // Botones de acciones
            _botonAccion(
              icon: Icons.calendar_today,
              label: 'Crear Planificación',
              color: AppColors.rojo,
              onTap: () => Navigator.pushNamed(context, '/planificacion'),
            ),
            _botonAccion(
              icon: Icons.description,
              label: 'Crear Reporte',
              color: AppColors.negro,
              onTap: () => Navigator.pushNamed(context, '/reporte'),
            ),
            _botonAccionOutlined(
              icon: Icons.search,
              label: 'Ver Reportes',
              borderColor: AppColors.rojo,
              textColor: AppColors.rojo,
              onTap: () => Navigator.pushNamed(context, '/historial_reportes'),
            ),
            _botonAccionOutlined(
              icon: Icons.calendar_month,
              label: 'Ver Planificaciones',
              borderColor: AppColors.rojo,
              textColor: AppColors.rojo,
              onTap: () =>
                  Navigator.pushNamed(context, '/historial_planificaciones'),
            ),

            // Solo visible para admin
            if (rol?.trim().toLowerCase() == 'admin')
              _botonAccion(
                icon: Icons.group,
                label: 'Ver Usuarios',
                color: Colors.blue.shade700,
                onTap: () => Navigator.pushNamed(context, '/ver_usuarios'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _botonAccion({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _botonAccionOutlined({
    required IconData icon,
    required String label,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton.icon(
        icon: Icon(icon, color: borderColor),
        label: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onTap,
      ),
    );
  }
}
