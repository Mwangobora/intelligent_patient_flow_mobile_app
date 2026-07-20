import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Queue Status',
      body: AppEmptyState(
        title: 'Queue status',
        message: 'Queue number and status tracking will be connected later.',
      ),
    );
  }
}
