import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identificadorController = TextEditingController(); // Email o RUT
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  Future<void> _login() async {
    final identificador = _identificadorController.text.trim();
    final password = _passwordController.text.trim();

    if (identificador.isEmpty || password.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      String emailToLogin = identificador;

      // Si no contiene '@', asumimos que es RUT y buscamos en Firestore
      if (!identificador.contains('@')) {
        final perfilesRef = FirebaseFirestore.instance.collection('perfiles');
        final snap = await perfilesRef
            .where('rut', isEqualTo: identificador.toUpperCase())
            .limit(1)
            .get();

        if (snap.docs.isEmpty) {
          throw Exception('No existe usuario con ese RUT');
        }

        final data = snap.docs.first.data();
        final email = (data['email'] ?? '').toString().trim();
        if (email.isEmpty) {
          throw Exception('El usuario con ese RUT no tiene email registrado');
        }
        emailToLogin = email;
      }

      // Autenticación con email obtenido o ingresado
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailToLogin,
        password: password,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = _identificadorController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _loading;

    return Scaffold(
      backgroundColor: AppColors.negro,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 32),

                Text(
                  'Iniciar Sesión',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.rojo,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Campo Email o RUT
                TextField(
                  controller: _identificadorController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email o RUT',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  onSubmitted: (_) => _login(),
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
                  onPressed: isDisabled ? null : _login,
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
                          'Ingresar',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 12),

                // Enlace a registro
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registro');
                  },
                  child: const Text(
                    '¿No tienes cuenta? Crea una',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}