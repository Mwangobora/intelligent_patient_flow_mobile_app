import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_scaffold.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(title: 'Register', body: RegisterForm());
  }
}
