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
  String? _loadedPatientId;

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
    final profileState = ref.watch(profileControllerProvider);
    final state = ref.watch(queueControllerProvider);
    final patient = profileState.patientProfiles.isEmpty
        ? null
        : profileState.patientProfiles.first;

    if (patient != null &&
        widget.queueEntryId == null &&
        _loadedPatientId != patient.id) {
      _loadedPatientId = patient.id;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _loadPatientQueue(patient.id),
      );
    }

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
      body: profileState.isLoading || state.isLoading
          ? const AppLoadingState(message: 'Loading queue status...')
          : state.errorMessage != null
          ? AppErrorState(
              message: state.errorMessage!,
              onRetry: () => _refresh(),
            )
          : patient == null && widget.queueEntryId == null
          ? const AppEmptyState(
              title: 'Patient profile unavailable',
              message:
                  'A linked patient profile is required to view queue status.',
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
                      prediction: state.prediction,
                      lastUpdatedAt: state.lastUpdatedAt,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Text(
                      'Queue history',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSizes.md),
                    QueueEventTimeline(events: state.events),
                  ],
                ],
              ),
            ),
    );
  }

  void _initialLoad() {
    final user = ref.read(authControllerProvider).user;
    if (user != null &&
        ref.read(profileControllerProvider).patientProfiles.isEmpty) {
      ref
          .read(profileControllerProvider.notifier)
          .loadLinkedPatientProfiles(user.id);
    }
    final entryId = widget.queueEntryId;
    if (entryId != null) {
      ref.read(queueControllerProvider.notifier).loadEntry(entryId);
    }
  }

  Future<void> _refresh({bool quiet = false}) async {
    final entryId = widget.queueEntryId;
    if (entryId != null) {
      await ref
          .read(queueControllerProvider.notifier)
          .loadEntry(entryId, quiet: quiet);
      return;
    }
    final profiles = ref.read(profileControllerProvider).patientProfiles;
    if (profiles.isNotEmpty) {
      await _loadPatientQueue(profiles.first.id, quiet: quiet);
    }
  }

  Future<void> _loadPatientQueue(String patientId, {bool quiet = false}) async {
    await ref
        .read(queueControllerProvider.notifier)
        .loadPatientQueue(patientId, quiet: quiet);
  }
}
