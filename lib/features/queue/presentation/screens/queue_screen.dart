import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../widgets/queue_widgets.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({this.queueEntryId, super.key});

  final String? queueEntryId;

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
    _pollTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => _refresh(quiet: true),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(queueControllerProvider);

    final entry = state.selectedEntry ?? state.currentEntry;

    return AppScaffold(
      title: 'Queue Status',
      showBottomNavigation: true,
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => _refresh(),
        ),
      ],
      body: state.isLoading
          ? const AppLoadingState(message: 'Loading queue status...')
          : state.errorMessage != null
          ? AppErrorState(
              message: state.errorMessage!,
              onRetry: () => _refresh(),
            )
          : RefreshIndicator(
              onRefresh: () => _refresh(),
              child: ListView(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (entry == null)
                    const AppEmptyState(
                      title: 'No active queue yet',
                      message:
                          'After check-in, your queue number will appear here.',
                    )
                  else ...[
                    QueueStatusCard(
                      entry: entry,
                      lastUpdatedAt: state.lastUpdatedAt,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Text(
                      'Queue history',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSizes.md),
                    QueueHistoryList(entries: state.entries),
                  ],
                ],
              ),
            ),
    );
  }

  void _initialLoad() {
    ref.read(queueControllerProvider.notifier).loadCurrentQueue();
  }

  Future<void> _refresh({bool quiet = false}) async {
    await _loadCurrentQueue(quiet: quiet);
  }

  Future<void> _loadCurrentQueue({bool quiet = false}) async {
    await ref
        .read(queueControllerProvider.notifier)
        .loadCurrentQueue(quiet: quiet);
  }
}
