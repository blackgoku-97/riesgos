import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/user_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _userController = TextEditingController();
  final _authService = AuthService();

  bool _userValid = false;
  bool _loading = false;
  String? _message;
  String? _error;

  @override
  void initState() {
    super.initState();
    _userController.addListener(() {
      _userValid = UserField.quickValidate(_userController.text, _authService);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final userInput = _userController.text.trim();

    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });

    try {
      String emailToUse = userInput;

      if (_authService.isValidRut(userInput.toUpperCase())) {
        final perfilesRef = _authService.db.collection('perfiles');
        final query = await perfilesRef
            .where('rut', isEqualTo: userInput.toUpperCase())
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw Exception('No existe un usuario con este RUT');
        }
        emailToUse = (query.docs.first.data()['email'] ?? '').toString().trim();
        if (emailToUse.isEmpty) {
          throw Exception('El perfil con ese RUT no tiene email asociado');
        }
      }

      await _authService.sendPasswordReset(emailToUse);

      setState(() {
        _message = 'Se ha enviado un enlace de recuperación a $emailToUse';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enlace enviado a $emailToUse')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
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
        title: const Text('Recuperar contraseña'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_reset, size: 80, color: Colors.white70),
                const SizedBox(height: 16),
                const Text(
                  'Ingresa tu correo o RUT y te enviaremos un enlace para restablecer tu contraseña.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                UserField(
                  controller: _userController,
                  isValid: _userValid,
                  errorText: _error,
                ),
                const SizedBox(height: 16),
                if (_message != null)
                  Text(
                    _message!,
                    style: const TextStyle(color: Colors.greenAccent),
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
                  onPressed: (!_userValid || _loading) ? null : _sendReset,
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
                          'Enviar enlace',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Volver al inicio de sesión',
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