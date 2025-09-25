import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/widgets/password_field.dart';
import '../../auth/widgets/user_field.dart';
import '../utils/rut_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  String? _error;
  bool _obscurePass = true;
  bool _userValid = false;
  bool _passValid = false;

  String? _userError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();

    _userController.addListener(() {
      final text = _userController.text.trim();
      if (text.isEmpty) {
        _userValid = false;
        _userError = null;
      } else if (!UserField.quickValidate(text, _authService)) {
        _userValid = false;
        _userError = 'Ingresa un correo válido o un RUT válido';
      } else {
        _userValid = true;
        _userError = null;
      }
      setState(() {});
    });

    _passwordController.addListener(() {
      final text = _passwordController.text.trim();
      if (text.isEmpty) {
        _passValid = false;
        _passwordError = null;
      } else if (!_authService.isValidPassword(text)) {
        _passValid = false;
        _passwordError = 'Debe tener mínimo 8 caracteres, 1 mayúscula y 1 número';
      } else {
        _passValid = true;
        _passwordError = null;
      }
      setState(() {});
    });
  }

  bool get _formValid => _userValid && _passValid;

  Future<void> _login() async {
    String userInput = _userController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      String emailToUse = userInput;

      if (_authService.isValidRUT(userInput.toUpperCase())) {
        final rutFormateado = formatRut(userInput.toUpperCase());
        final perfilesRef = _authService.db.collection('perfiles');
        final query = await perfilesRef
            .where('rutFormateado', isEqualTo: rutFormateado)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw Exception('No existe un usuario con este RUT');
        }
        emailToUse = query.docs.first['email'];
      }

      await _authService.loginUser(email: emailToUse, password: password);

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
                UserField(
                  controller: _userController,
                  isValid: _userValid,
                  errorText: _userError,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscure: _obscurePass,
                  onToggleVisibility: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  isValid: _passValid,
                  helperText: 'Mínimo 8 caracteres, 1 mayúscula y 1 número',
                  errorText: _passwordError,
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/register'),
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