import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/widgets/password_field.dart';
import '../../auth/widgets/email_autocomplete_field.dart';
import '../../auth/widgets/rut_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _rutController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  String? _error;
  bool _emailValid = false;
  bool _rutValid = false;
  bool _passValid = false;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      final text = _emailController.text.trim();
      _emailValid = text.isNotEmpty && _authService.isValidEmail(text);
      setState(() {});
    });

    _rutController.addListener(() {
      final text = _rutController.text.trim();
      _rutValid = text.isNotEmpty && _authService.isValidRut(text);
      setState(() {});
    });

    _passwordController.addListener(() {
      final text = _passwordController.text.trim();
      _passValid = text.isNotEmpty && _authService.isValidPassword(text);
      setState(() {});
    });
  }

  bool get _formValid => (_emailValid || _rutValid) && _passValid;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userInput = _emailValid
          ? _emailController.text.trim()
          : _rutController.text.trim();

      final nav = Navigator.of(context); // capturamos antes del await
      await _authService.loginUserFlexible(
        userInput: userInput,
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      nav.pushReplacementNamed('/dashboard');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _rutController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                EmailAutocompleteField(
                  controller: _emailController,
                  isValid: _emailValid,
                  errorText: !_emailValid && _emailController.text.isNotEmpty
                      ? 'Correo inválido'
                      : null,
                ),
                const SizedBox(height: 16),
                RutField(
                  controller: _rutController,
                  isValid: _rutValid,
                  errorText: !_rutValid && _rutController.text.isNotEmpty
                      ? 'RUT inválido'
                      : null,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscure: _obscurePass,
                  onToggleVisibility: () =>
                      setState(() => _obscurePass = !_obscurePass),
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
                          'Ingresar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (_emailValid) {
                      final messenger = ScaffoldMessenger.of(context); // capturamos antes del await
                      try {
                        await _authService.sendPasswordReset(
                          _emailController.text.trim(),
                        );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Se envió un correo para restablecer la contraseña',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
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