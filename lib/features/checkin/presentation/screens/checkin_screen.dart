import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class CheckinScreen extends StatelessWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'QR Check-in',
      body: AppEmptyState(
        title: 'Secure check-in',
        message: 'QR token display and scanner workflows will be added later.',
      ),
    );
  }
}
