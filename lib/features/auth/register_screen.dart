import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import '../auth/widgets/custom_text_field.dart';
import '../auth/widgets/password_field.dart';
import '../auth/widgets/rut_field.dart';
import '../auth/widgets/email_field.dart';

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

  final _authService = AuthService();

  bool _loading = false;
  String? _error;

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  bool _emailValid = false;
  bool _rutValid = false;
  bool _passValid = false;
  bool _nombreValid = false;
  bool _cargoValid = false;

  // 👇 mensajes de error específicos
  String? _rutError;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      final text = _emailController.text.trim();
      if (text.isEmpty) {
        _emailValid = false;
        _emailError = null;
      } else if (!_authService.isValidEmail(text)) {
        _emailValid = false;
        _emailError = 'El correo electrónico no es válido';
      } else {
        _emailValid = true;
        _emailError = null;
      }
      setState(() {});
    });

    _rutController.addListener(() {
      final text = _rutController.text.trim().toUpperCase();
      final rutPattern = RegExp(r'^\d{1,2}\.?\d{3}\.?\d{3}-[\dkK]$');

      if (text.isEmpty) {
        _rutValid = false;
        _rutError = null;
      } else if (!rutPattern.hasMatch(text)) {
        _rutValid = false;
        _rutError = 'Formato inválido. Ej: 12.345.678-5';
      } else if (!_authService.isValidRUT(text)) {
        _rutValid = false;
        _rutError = 'El RUT ingresado no es válido';
      } else {
        _rutValid = true;
        _rutError = null;
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

    _nombreController.addListener(() {
      _nombreValid = _authService.startsWithCapital(_nombreController.text.trim());
      setState(() {});
    });

    _cargoController.addListener(() {
      _cargoValid = _authService.startsWithCapital(_cargoController.text.trim());
      setState(() {});
    });

    _confirmController.addListener(() => setState(() {}));
  }

  bool get _confirmValid {
    final c = _confirmController.text.trim();
    return c.isNotEmpty && c == _passwordController.text.trim() && _passValid;
  }

  bool get _formValid =>
      _nombreValid && _rutValid && _cargoValid && _emailValid && _passValid && _confirmValid;

  Future<void> _register() async {
    if (!_formValid) {
      setState(() => _error = 'Por favor, completa todos los campos correctamente.');
      return;
    }

    final nombre = _authService.capitalize(_nombreController.text.trim());
    final rut = _rutController.text.trim().toUpperCase();
    final cargo = _authService.capitalize(_cargoController.text.trim());
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.registerUser(
        nombre: nombre,
        rut: rut,
        cargo: cargo,
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rutController.dispose();
    _cargoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

                CustomTextField(
                  controller: _nombreController,
                  label: 'Nombre completo',
                  borderColor: _nombreController.text.isEmpty
                      ? null
                      : _nombreValid
                          ? Colors.green
                          : Colors.red,
                ),
                const SizedBox(height: 16),

                RutField(
                  controller: _rutController,
                  isValid: _rutValid,
                  errorText: _rutError, // 👈 mensaje debajo del campo
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _cargoController,
                  label: 'Cargo',
                  borderColor: _cargoController.text.isEmpty
                      ? null
                      : _cargoValid
                          ? Colors.green
                          : Colors.red,
                ),
                const SizedBox(height: 16),

                EmailField(
                  controller: _emailController,
                  isValid: _emailValid,
                  errorText: _emailError, // 👈 mensaje debajo del campo
                ),
                const SizedBox(height: 16),

                PasswordField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscure: _obscurePass,
                  onToggleVisibility: () => setState(() => _obscurePass = !_obscurePass),
                  isValid: _passValid,
                  helperText: 'Mínimo 8 caracteres, 1 mayúscula y 1 número',
                  errorText: _passwordError, // 👈 mensaje debajo del campo
                ),
                const SizedBox(height: 16),

                PasswordField(
                  controller: _confirmController,
                  label: 'Confirmar contraseña',
                  obscure: _obscureConfirm,
                  onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  isValid: _confirmValid,
                  helperText: _confirmController.text.isEmpty
                      ? ''
                      : _confirmValid
                          ? 'Coincide con la contraseña'
                          : 'Las contraseñas no coinciden',
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
                  onPressed: (!_formValid || _loading) ? null : _register,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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