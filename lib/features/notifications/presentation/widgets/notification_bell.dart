import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/notification_realtime_service.dart';

class NotificationBell extends ConsumerStatefulWidget {
  const NotificationBell({super.key});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  StreamSubscription<NotificationRealtimeEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectRealtime());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(
      notificationsControllerProvider.select((state) => state.unreadCount),
    );
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => context.go('/notifications'),
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
        backgroundColor: AppColors.danger,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }

  Future<void> _connectRealtime() async {
    if (_subscription != null) return;
    try {
      final stream = await ref
          .read(notificationRealtimeServiceProvider)
          .connect();
      _subscription = stream.listen(
        (event) {
          final notification = event.notification;
          if (notification == null) return;
          ref
              .read(notificationsControllerProvider.notifier)
              .applyRealtimeNotification(notification);
        },
        onError: (_) {},
        onDone: () {
          _subscription = null;
        },
      );
    } catch (_) {
      // Initial REST loading still keeps the badge usable when realtime is offline.
    }
  }
}
