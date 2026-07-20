import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_result.dart';
import '../../data/models/notification_models.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.selectedNotification,
    this.showUnreadOnly = false,
    this.isLoading = false,
    this.isActionLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  final List<PatientNotification> notifications;
  final PatientNotification? selectedNotification;
  final bool showUnreadOnly;
  final bool isLoading;
  final bool isActionLoading;
  final String? successMessage;
  final String? errorMessage;

  int get unreadCount => notifications.where((item) => item.isUnread).length;

  List<PatientNotification> get visibleNotifications {
    if (!showUnreadOnly) return notifications;
    return notifications.where((item) => item.isUnread).toList();
  }

  NotificationsState copyWith({
    List<PatientNotification>? notifications,
    PatientNotification? selectedNotification,
    bool clearSelectedNotification = false,
    bool? showUnreadOnly,
    bool? isLoading,
    bool? isActionLoading,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      selectedNotification: clearSelectedNotification
          ? null
          : selectedNotification ?? this.selectedNotification,
      showUnreadOnly: showUnreadOnly ?? this.showUnreadOnly,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class NotificationsController extends StateNotifier<NotificationsState> {
  NotificationsController({required this.repository})
    : super(const NotificationsState());

  final NotificationsRepository repository;

  Future<void> loadNotifications(String patientId, {bool quiet = false}) async {
    if (!quiet) state = state.copyWith(isLoading: true, clearMessages: true);
    final result = await repository.listNotifications(
      patientId: patientId,
      unreadOnly: false,
    );
    switch (result) {
      case ApiSuccess(data: final notifications):
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        state = state.copyWith(
          notifications: notifications,
          isLoading: false,
          clearMessages: true,
        );
      case ApiFailure(message: final message):
        state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  Future<void> loadNotificationDetail(String notificationId) async {
    state = state.copyWith(
      isLoading: true,
      clearMessages: true,
      clearSelectedNotification: true,
    );
    final result = await repository.getNotification(notificationId);
    switch (result) {
      case ApiSuccess(data: final notification):
        state = state.copyWith(
          selectedNotification: notification,
          isLoading: false,
        );
      case ApiFailure(message: final message):
        state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    state = state.copyWith(isActionLoading: true, clearMessages: true);
    final result = await repository.markAsRead(notificationId);
    switch (result) {
      case ApiSuccess(data: final notification):
        state = state.copyWith(
          selectedNotification: notification,
          notifications: [
            for (final item in state.notifications)
              item.id == notification.id ? notification : item,
          ],
          isActionLoading: false,
          successMessage: 'Notification marked as read.',
        );
        return true;
      case ApiFailure(message: final message):
        state = state.copyWith(isActionLoading: false, errorMessage: message);
        return false;
    }
  }

  void setUnreadOnly(bool value) {
    state = state.copyWith(showUnreadOnly: value, clearMessages: true);
  }
}
