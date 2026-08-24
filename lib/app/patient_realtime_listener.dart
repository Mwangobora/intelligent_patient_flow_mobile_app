import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/notifications/data/models/notification_models.dart';
import '../features/notifications/data/notification_realtime_service.dart';
import '../features/queue/data/queue_realtime_service.dart';
import 'app_providers.dart';

class PatientRealtimeListener extends ConsumerStatefulWidget {
  const PatientRealtimeListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PatientRealtimeListener> createState() =>
      _PatientRealtimeListenerState();
}

class _PatientRealtimeListenerState
    extends ConsumerState<PatientRealtimeListener> {
  StreamSubscription<NotificationRealtimeEvent>? _notificationSubscription;
  StreamSubscription<QueueRealtimeEvent>? _queueSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncConnections());
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next.status == AuthStatus.authenticated) {
        _syncConnections();
      } else {
        _disconnect();
      }
    });
    return widget.child;
  }

  Future<void> _syncConnections() async {
    if (ref.read(authControllerProvider).status != AuthStatus.authenticated) {
      return;
    }
    await Future.wait([_connectNotifications(), _connectQueue()]);
  }

  Future<void> _connectNotifications() async {
    if (_notificationSubscription != null) return;
    try {
      final stream = await ref
          .read(notificationRealtimeServiceProvider)
          .connect();
      _notificationSubscription = stream.listen(
        _handleNotificationEvent,
        onError: (_) {
          _notificationSubscription = null;
        },
        onDone: () {
          _notificationSubscription = null;
        },
      );
    } catch (_) {
      // REST refresh remains available if realtime is temporarily offline.
    }
  }

  Future<void> _connectQueue() async {
    if (_queueSubscription != null) return;
    try {
      final stream = await ref.read(queueRealtimeServiceProvider).connect();
      _queueSubscription = stream.listen(
        _handleQueueEvent,
        onError: (_) {
          _queueSubscription = null;
        },
        onDone: () {
          _queueSubscription = null;
        },
      );
    } catch (_) {
      // Queue screen polling remains the fallback when websocket is unavailable.
    }
  }

  void _handleNotificationEvent(NotificationRealtimeEvent event) {
    final notification = event.notification;
    if (notification == null || !mounted) return;

    ref
        .read(notificationsControllerProvider.notifier)
        .applyRealtimeNotification(notification);

    if (notification.queueEntryId != null) {
      ref.read(queueControllerProvider.notifier).loadCurrentQueue(quiet: true);
    }

    _showMessage(_notificationMessage(notification));
  }

  void _handleQueueEvent(QueueRealtimeEvent event) {
    ref
        .read(queueControllerProvider.notifier)
        .applyRealtimeQueueEntry(event.queueEntry);

    if (event.event == 'position_updated' && event.queueEntry != null) {
      _showMessage(_queuePositionMessage(event.queueEntry!.queuePosition));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _disconnect() async {
    await _notificationSubscription?.cancel();
    await _queueSubscription?.cancel();
    _notificationSubscription = null;
    _queueSubscription = null;
  }
}

String _notificationMessage(PatientNotification notification) {
  return switch (notification.notificationType) {
    PatientNotificationType.queueCalled =>
      'You have been called. Please proceed to reception.',
    PatientNotificationType.queueUpdated =>
      'Your queue has changed. Please check your next step.',
    PatientNotificationType.queueJoined =>
      'You have been added to the hospital queue.',
    PatientNotificationType.appointmentReminder =>
      'You have an upcoming appointment reminder.',
    PatientNotificationType.appointmentCancelled =>
      'Your appointment was cancelled.',
    PatientNotificationType.appointmentRescheduled =>
      'Your appointment was rescheduled.',
    PatientNotificationType.appointmentConfirmation =>
      'Your appointment is confirmed.',
    _ => 'You have a new notification.',
  };
}

String _queuePositionMessage(int? peopleAhead) {
  if (peopleAhead == null) return 'Your queue position was updated.';
  if (peopleAhead <= 0) return 'You are next in the queue.';
  if (peopleAhead == 1) return 'Queue updated: 1 patient is in front of you.';
  return 'Queue updated: $peopleAhead patients are in front of you.';
}
