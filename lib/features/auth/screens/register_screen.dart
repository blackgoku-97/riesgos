import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/widgets/password_field.dart';
import '../utils/rut_utils.dart';
import '../formatters/rut_input_formatter.dart' as formatters;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _cargoController = TextEditingController();
  final _emailController = TextEditingController();
  final _rutController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  String? _error;

  bool _nombreValid = false;
  bool _cargoValid = false;
  bool _emailValid = false;
  bool _rutValid = false;
  bool _passValid = false;
  bool _confirmValid = false;

  String? _nombreError;
  String? _cargoError;
  String? _emailError;
  String? _rutError;
  String? _passwordError;
  String? _confirmError;

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();

    _nombreController.addListener(() {
      final text = _nombreController.text.trim();
      if (text.isEmpty) {
        _nombreValid = false;
        _nombreError = null;
      } else if (!_authService.startsWithCapital(text)) {
        _nombreValid = false;
        _nombreError = 'Debe comenzar con mayúscula';
      } else {
        _nombreValid = true;
        _nombreError = null;
      }
      setState(() {});
    });

    _cargoController.addListener(() {
      final text = _cargoController.text.trim();
      if (text.isEmpty) {
        _cargoValid = false;
        _cargoError = null;
      } else if (!_authService.startsWithCapital(text)) {
        _cargoValid = false;
        _cargoError = 'Debe comenzar con mayúscula';
      } else {
        _cargoValid = true;
        _cargoError = null;
      }
      setState(() {});
    });

    _emailController.addListener(() {
      final text = _emailController.text.trim();
      if (text.isEmpty) {
        _emailValid = false;
        _emailError = null;
      } else if (!_authService.isValidEmail(text)) {
        _emailValid = false;
        _emailError = 'Correo inválido';
      } else {
        _emailValid = true;
        _emailError = null;
      }
      setState(() {});
    });

    _rutController.addListener(() {
      final text = _rutController.text.trim();
      if (text.isEmpty) {
        _rutValid = false;
        _rutError = null;
      } else if (!validarRut(text)) {
        _rutValid = false;
        _rutError = 'RUT inválido';
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
        _passwordError = 'Máximo 8 caracteres';
      } else {
        _passValid = true;
        _passwordError = null;
      }
      _validateConfirm();
      setState(() {});
    });

    _confirmController.addListener(() {
      _validateConfirm();
      setState(() {});
    });
  }

  void _validateConfirm() {
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (confirm.isEmpty) {
      _confirmValid = false;
      _confirmError = null;
    } else if (confirm != pass) {
      _confirmValid = false;
      _confirmError = 'Las contraseñas no coinciden';
    } else {
      _confirmValid = true;
      _confirmError = null;
    }
  }

  bool get _formValid =>
      _nombreValid &&
      _cargoValid &&
      _emailValid &&
      _rutValid &&
      _passValid &&
      _confirmValid;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rutInput = _rutController.text.trim().toUpperCase();
      final rutFormateado = formatRut(rutInput);

      await _authService.registerUser(
        nombre: _nombreController.text.trim(),
        cargo: _cargoController.text.trim(),
        rutFormateado: rutFormateado,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

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
                TextField(
                  controller: _nombreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: const TextStyle(color: Colors.white70),
                    errorText: _nombreError,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _cargoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Cargo',
                    labelStyle: const TextStyle(color: Colors.white70),
                    errorText: _cargoError,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: const TextStyle(color: Colors.white70),
                    errorText: _emailError,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _rutController,
                  inputFormatters: [formatters.RutInputFormatter()],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'RUT',
                    labelStyle: const TextStyle(color: Colors.white70),
                    errorText: _rutError,
                  ),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscure: _obscurePass,
                  onToggleVisibility: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  isValid: _passValid,
                  helperText: 'Máximo 8 caracteres',
                  errorText: _passwordError,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirmController,
                  label: 'Confirmar contraseña',
                  obscure: _obscureConfirm,
                  onToggleVisibility: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  isValid: _confirmValid,
                  errorText: _confirmError,
                  helperText: '',
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
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión',
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
