import 'dart:async';
import 'package:flutter/material.dart';

class EmailAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final bool isValid;
  final String? errorText;

  const EmailAutocompleteField({
    super.key,
    required this.controller,
    required this.isValid,
    this.errorText,
  });

  @override
  State<EmailAutocompleteField> createState() => _EmailAutocompleteFieldState();
}

class _EmailAutocompleteFieldState extends State<EmailAutocompleteField> {
  final List<String> dominios = ['gmail.com', 'outlook.com', 'hotmail.com', 'phos-chek.cl'];

  Timer? _debounce;
  Iterable<String> _options = const [];

  void _onTextChanged(String value) {
    // Cancelar debounce previo
    _debounce?.cancel();

    // Esperar 150ms antes de calcular sugerencias
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
        return TextField(
          controller: widget.controller,
          focusNode: focusNode,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white10,
            errorText: widget.errorText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.controller.text.isEmpty
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
                color: widget.controller.text.isEmpty
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