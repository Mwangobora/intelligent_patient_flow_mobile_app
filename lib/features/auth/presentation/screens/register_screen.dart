import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Register',
      body: AppEmptyState(
        title: 'Patient registration',
        message:
            'Registration workflow will be connected after mobile auth APIs are finalized.',
      ),
    );
  }
}
