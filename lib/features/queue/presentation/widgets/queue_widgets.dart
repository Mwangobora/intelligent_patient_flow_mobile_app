import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../data/models/queue_models.dart';

class QueueStatusCard extends StatelessWidget {
  const QueueStatusCard({
    required this.entry,
    required this.prediction,
    required this.lastUpdatedAt,
    super.key,
  });

  final QueueEntry entry;
  final WaitTimePrediction? prediction;
  final DateTime? lastUpdatedAt;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppStatusBadge(
            label: _statusText(entry.status),
            color: _statusColor(entry.status),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            entry.displayQueueNumber,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.darkNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(_nextInstruction(entry), textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.lg),
          _QueueInfoGrid(entry: entry, prediction: prediction),
          if (lastUpdatedAt != null) ...[
            const SizedBox(height: AppSizes.md),
            Text(
              'Last updated ${DateFormatter.readableDateTime(lastUpdatedAt!)}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class QueueEventTimeline extends StatelessWidget {
  const QueueEventTimeline({required this.events, super.key});

  final List<QueueEntryEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const AppCard(child: Text('No queue history is available yet.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: events
          .map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _eventIcon(event.eventType),
                    color: AppColors.primaryTeal,
                  ),
                  title: Text(_eventLabel(event.eventType)),
                  subtitle: Text(
                    '${DateFormatter.readableDateTime(event.occurredAt)}'
                    '${event.reason == null ? '' : '\n${event.reason}'}',
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QueueInfoGrid extends StatelessWidget {
  const _QueueInfoGrid({required this.entry, required this.prediction});

  final QueueEntry entry;
  final WaitTimePrediction? prediction;

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoItem('Service point', entry.servicePointName ?? 'Not available'),
      _InfoItem('People ahead', entry.queuePosition?.toString() ?? '—'),
      _InfoItem('Priority', _priorityLabel(entry.priorityLevel)),
      _InfoItem(
        'Estimated wait',
        prediction == null ? '—' : '${prediction!.predictedWaitMinutes} min',
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.3,
      crossAxisSpacing: AppSizes.sm,
      mainAxisSpacing: AppSizes.sm,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items
          .map(
            (item) => DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.softCyan,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      item.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String value;
}

String _statusText(String status) {
  return switch (status) {
    QueueEntryStatus.waiting => 'You are waiting',
    QueueEntryStatus.called => 'Please proceed to the service desk',
    QueueEntryStatus.inService => 'You are being served',
    QueueEntryStatus.completed => 'Your visit is completed',
    QueueEntryStatus.skipped => 'You were skipped',
    QueueEntryStatus.cancelled => 'Queue entry cancelled',
    QueueEntryStatus.transferred => 'Transferred',
    _ => status,
  };
}

String _nextInstruction(QueueEntry entry) {
  return switch (entry.status) {
    QueueEntryStatus.called =>
      'Please proceed to ${entry.servicePointName ?? 'the service desk'}.',
    QueueEntryStatus.skipped => 'Please contact reception for assistance.',
    QueueEntryStatus.inService => 'Your service has started.',
    QueueEntryStatus.completed => 'Thank you. Your visit is completed.',
    QueueEntryStatus.cancelled =>
      'Please contact reception if this is unexpected.',
    QueueEntryStatus.transferred =>
      'Please follow the updated queue instructions.',
    _ => 'Please stay nearby and watch for your queue number.',
  };
}

Color _statusColor(String status) {
  return switch (status) {
    QueueEntryStatus.called => AppColors.info,
    QueueEntryStatus.inService => AppColors.primaryTeal,
    QueueEntryStatus.completed => AppColors.success,
    QueueEntryStatus.skipped ||
    QueueEntryStatus.transferred => AppColors.warning,
    QueueEntryStatus.cancelled => AppColors.danger,
    _ => AppColors.textSecondary,
  };
}

String _priorityLabel(int priority) {
  return switch (priority) {
    1 => 'Priority',
    2 => 'Urgent',
    3 => 'Emergency',
    _ => 'Normal',
  };
}

String _eventLabel(String eventType) {
  return eventType
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

IconData _eventIcon(String eventType) {
  return switch (eventType) {
    'called' || 'recalled' => Icons.notifications_active_outlined,
    'service_started' => Icons.play_circle_outline,
    'service_completed' => Icons.check_circle_outline,
    'cancelled' => Icons.cancel_outlined,
    'transferred' => Icons.arrow_forward,
    'priority_changed' => Icons.priority_high,
    _ => Icons.history,
  };
}
