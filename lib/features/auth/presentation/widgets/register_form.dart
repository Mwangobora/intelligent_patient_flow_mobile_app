import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_password_field.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    required this.onSubmit,
    required this.isLoading,
    super.key,
  });

  final Future<void> Function(RegisterFormData data) onSubmit;
  final bool isLoading;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+255');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _sexCode = 'unknown';

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      showAppErrorSnackBar(
        context,
        'Please complete the required fields before creating your account.',
      );
      return;
    }
    await widget.onSubmit(
      RegisterFormData(
        firstName: _firstNameController.text.trim(),
        middleName: _emptyToNull(_middleNameController.text),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _emptyToNull(_dateOfBirthController.text),
        sexCode: _sexCode,
        email: _emptyToNull(_emailController.text),
        phoneNumber: _phoneOrNull(_phoneController.text),
        password: _passwordController.text,
        passwordConfirm: _confirmPasswordController.text,
      ),
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
            label: 'First name',
            controller: _firstNameController,
            validator: (value) =>
                Validators.required(value, field: 'First name'),
          ),
          const SizedBox(height: AppSizes.md),
          AppTextField(label: 'Middle name', controller: _middleNameController),
          const SizedBox(height: AppSizes.md),
          AppTextField(
            label: 'Last name',
            controller: _lastNameController,
            validator: (value) =>
                Validators.required(value, field: 'Last name'),
          ),
          const SizedBox(height: AppSizes.md),
          AppTextField(
            label: 'Date of birth',
            hintText: 'YYYY-MM-DD',
            controller: _dateOfBirthController,
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: AppSizes.md),
          DropdownButtonFormField<String>(
            initialValue: _sexCode,
            decoration: const InputDecoration(labelText: 'Sex'),
            items: const [
              DropdownMenuItem(
                value: 'unknown',
                child: Text('Prefer not to say'),
              ),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'intersex', child: Text('Intersex')),
            ],
            onChanged: widget.isLoading
                ? null
                : (value) => setState(() => _sexCode = value),
          ),
          const SizedBox(height: AppSizes.md),
          AppTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: AppSizes.md),
          AppTextField(
            label: 'Phone number',
            hintText: '+255...',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
          const SizedBox(height: AppSizes.md),
          AppPasswordField(
            label: 'Password',
            controller: _passwordController,
            validator: (value) => Validators.required(value, field: 'Password'),
          ),
          const SizedBox(height: AppSizes.md),
          AppPasswordField(
            label: 'Confirm password',
            controller: _confirmPasswordController,
            validator: _validatePasswordConfirm,
          ),
          const SizedBox(height: AppSizes.lg),
          AppButton(
            label: 'Create account',
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  String? _validatePasswordConfirm(String? value) {
    final required = Validators.required(value, field: 'Confirm password');
    if (required != null) return required;
    if (value != _passwordController.text) return 'Passwords do not match.';
    return null;
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _phoneOrNull(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '+255') return null;
    return trimmed;
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == '+255') return null;
    if (trimmed.startsWith('+255') && trimmed.length < 13) {
      return 'Enter a complete Tanzanian phone number.';
    }
    if (trimmed.startsWith('0') && trimmed.length < 10) {
      return 'Enter a complete Tanzanian phone number.';
    }
    return null;
  }
}

class RegisterFormData {
  const RegisterFormData({
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.passwordConfirm,
    this.middleName,
    this.dateOfBirth,
    this.sexCode,
    this.email,
    this.phoneNumber,
  });

  final String firstName;
  final String? middleName;
  final String lastName;
  final String? dateOfBirth;
  final String? sexCode;
  final String? email;
  final String? phoneNumber;
  final String password;
  final String passwordConfirm;
}
