import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import '../auth/widgets/email_field.dart';
import '../auth/widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  bool _loading = false;
  String? _error;
  bool _obscurePass = true;

  bool _emailValid = false;
  bool _passValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() => _emailValid = _authService.isValidEmail(_emailController.text.trim())));
    _passwordController.addListener(() => setState(() => _passValid = _authService.isValidPassword(_passwordController.text.trim())));
  }

  bool get _formValid => _emailValid && _passValid;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.loginUser(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      appBar: AppBar(
        backgroundColor: AppColors.negro,
        title: const Text('Iniciar sesión'),
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

                EmailField(
                  controller: _emailController,
                  isValid: _emailValid,
                ),
                const SizedBox(height: 16),

                PasswordField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscure: _obscurePass,
                  onToggleVisibility: () => setState(() => _obscurePass = !_obscurePass),
                  isValid: _passValid,
                  helperText: 'Mínimo 8 caracteres, 1 mayúscula y 1 número',
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
                  onPressed: (!_formValid || _loading) ? null : _login,
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
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.white70),
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