import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      title: 'Patient registration is not available yet',
      message:
          'The backend currently exposes staff user auth and staff-managed patient records, but no patient self-registration endpoint.',
    );
  }
}
