import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_password_field.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    required this.onSubmit,
    required this.isLoading,
    required this.registrationSupported,
    super.key,
  });

  final Future<void> Function(String emailOrPhone, String password) onSubmit;
  final bool isLoading;
  final bool registrationSupported;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.onSubmit(
      _emailOrPhoneController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Email or phone',
            controller: _emailOrPhoneController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                Validators.required(value, field: 'Email or phone'),
          ),
          const SizedBox(height: 16),
          AppPasswordField(
            label: 'Password',
            controller: _passwordController,
            validator: (value) => Validators.required(value, field: 'Password'),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Sign in',
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
          if (widget.registrationSupported)
            TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () => context.go('/register'),
              child: const Text('Create patient account'),
            ),
        ],
      ),
    );
  }
}
