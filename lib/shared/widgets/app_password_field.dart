import 'package:flutter/material.dart';

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    required this.label,
    this.controller,
    this.validator,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}
