import 'dart:async';
import 'package:flutter/material.dart';
import '../formatters/user_input_formatter.dart';
import '../services/auth_service.dart';

class UserField extends StatefulWidget {
  final TextEditingController controller;
  final bool isValid;
  final String? errorText;

  const UserField({
    super.key,
    required this.controller,
    required this.isValid,
    this.errorText,
  });

  /// Validación rápida: acepta email válido o RUT válido
  static bool quickValidate(String input, AuthService authService) {
    final text = input.trim();
    if (text.isEmpty) return false;
    return authService.isValidEmail(text) || authService.isValidRUT(text.toUpperCase());
  }

  @override
  State<UserField> createState() => _UserFieldState();
}

class _UserFieldState extends State<UserField> {
  final List<String> dominios = ['gmail.com', 'outlook.com', 'hotmail.com', 'phos-chek.cl'];

  Timer? _debounce;
  Iterable<String> _options = const [];

  void _onTextChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (!value.contains('@')) {
        setState(() => _options = const []);
        return;
      }

      final prefix = value.split('@').first;
      final typedDomain = value.split('@').last;

      final matches = dominios
          .where((d) => d.startsWith(typedDomain))
          .map((d) => '$prefix@$d');

      setState(() => _options = matches);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        _onTextChanged(textEditingValue.text);
        return _options;
      },
      onSelected: (String selection) {
        widget.controller.text = selection;
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        // 🔑 sincronizamos el controller externo con el interno
        textEditingController.addListener(() {
          if (widget.controller.text != textEditingController.text) {
            widget.controller.value = textEditingController.value;
          }
        });

        return TextField(
          controller: textEditingController, // 👈 usar el de Autocomplete
          focusNode: focusNode,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          inputFormatters: [UserInputFormatter()],
          decoration: InputDecoration(
            labelText: 'Correo o RUT',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white10,
            errorText: widget.errorText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: textEditingController.text.isEmpty
                    ? Colors.transparent
                    : widget.isValid
                        ? Colors.green
                        : Colors.red,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: textEditingController.text.isEmpty
                    ? Colors.blue
                    : widget.isValid
                        ? Colors.green
                        : Colors.red,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}