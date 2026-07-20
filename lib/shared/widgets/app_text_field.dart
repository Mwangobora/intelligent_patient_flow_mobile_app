import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.validator,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}
