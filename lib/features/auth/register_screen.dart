import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _rutController = TextEditingController();
  final _cargoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    final nombre = _nombreController.text.trim();
    final rut = _rutController.text.trim().toUpperCase();
    final cargo = _cargoController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (nombre.isEmpty ||
        rut.isEmpty ||
        cargo.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final perfilesRef = FirebaseFirestore.instance.collection('perfiles');

      // 🔹 Contar cuántos usuarios existen
      int totalUsuarios;
      try {
        // Método moderno (requiere SDK Firestore 4.8.0+)
        final countSnap = await perfilesRef.count().get();
        totalUsuarios = countSnap.count ?? 0;
      } catch (_) {
        // Fallback si count() no está disponible
        final snap = await perfilesRef.get();
        totalUsuarios = snap.docs.length;
      }

      // 🔹 Asignar rol
      final rol = totalUsuarios < 3 ? 'admin' : 'usuario';

      // 🔹 Crear usuario en Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔹 Guardar datos adicionales en Firestore
      await perfilesRef.doc(cred.user!.uid).set({
        'nombre': nombre,
        'rut': rut,
        'cargo': cargo,
        'email': email,
        'rol': rol,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = _nombreController.text.trim().isEmpty ||
        _rutController.text.trim().isEmpty ||
        _cargoController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmController.text.trim().isEmpty ||
        _loading;

    return Scaffold(
      backgroundColor: AppColors.negro,
      appBar: AppBar(
        backgroundColor: AppColors.negro,
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 32),

                // Nombre
                TextField(
                  controller: _nombreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Nombre completo'),
                ),
                const SizedBox(height: 16),

                // RUT
                TextField(
                  controller: _rutController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('RUT'),
                ),
                const SizedBox(height: 16),

                // Cargo
                TextField(
                  controller: _cargoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Cargo'),
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Correo electrónico'),
                ),
                const SizedBox(height: 16),

                // Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePass,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Contraseña').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirmar contraseña
                TextField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Confirmar contraseña').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rojo,
                    foregroundColor: AppColors.blanco,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isDisabled ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Crear cuenta',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}