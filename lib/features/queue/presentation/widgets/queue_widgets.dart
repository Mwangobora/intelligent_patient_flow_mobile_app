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
    required this.lastUpdatedAt,
    super.key,
  });

  final QueueEntry entry;
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
          _QueueInfoGrid(entry: entry),
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

class QueueHistoryList extends StatelessWidget {
  const QueueHistoryList({required this.entries, super.key});

  final List<QueueEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const AppCard(child: Text('No queue history is available yet.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _historyIcon(entry.status),
                    color: AppColors.primaryTeal,
                  ),
                  title: Text(entry.displayQueueNumber),
                  subtitle: Text(
                    '${_statusText(entry.status)}'
                    '\nJoined ${DateFormatter.readableDateTime(entry.joinedAt)}',
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
  const _QueueInfoGrid({required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoItem('Service point', entry.servicePointName ?? 'Not available'),
      _InfoItem('People ahead', entry.queuePosition?.toString() ?? '—'),
      _InfoItem(
        'Priority',
        entry.priorityLabel ?? _priorityLabel(entry.priorityLevel),
      ),
      _InfoItem(
        'Estimated wait',
        entry.estimatedWaitMinutes == null
            ? '—'
            : '${entry.estimatedWaitMinutes} min',
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

IconData _historyIcon(String status) {
  return switch (status) {
    QueueEntryStatus.called => Icons.notifications_active_outlined,
    QueueEntryStatus.inService => Icons.play_circle_outline,
    QueueEntryStatus.completed => Icons.check_circle_outline,
    QueueEntryStatus.cancelled => Icons.cancel_outlined,
    QueueEntryStatus.transferred => Icons.arrow_forward,
    _ => Icons.history,
  };
}
