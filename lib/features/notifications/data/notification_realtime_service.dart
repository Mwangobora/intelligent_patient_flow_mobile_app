import 'dart:async';
import 'dart:convert';

import '../../../core/network/realtime_client.dart';
import 'models/notification_models.dart';

class NotificationRealtimeEvent {
  const NotificationRealtimeEvent({
    required this.type,
    this.event,
    this.notification,
  });

  final String type;
  final String? event;
  final PatientNotification? notification;

  factory NotificationRealtimeEvent.fromJson(Map<String, dynamic> json) {
    final notificationJson = json['notification'];
    return NotificationRealtimeEvent(
      type: json['type'] as String? ?? '',
      event: json['event'] as String?,
      notification: notificationJson is Map<String, dynamic>
          ? PatientNotification.fromJson(notificationJson)
          : null,
    );
  }
}

class NotificationRealtimeService {
  const NotificationRealtimeService(this._realtimeClient);

  final RealtimeClient _realtimeClient;

  Future<Stream<NotificationRealtimeEvent>> connect() async {
    final channel = await _realtimeClient.connect('/ws/patient/notifications/');
    final controller = StreamController<NotificationRealtimeEvent>.broadcast();
    late final StreamSubscription<dynamic> subscription;

    subscription = channel.stream.listen(
      (message) {
        final decoded = jsonDecode(message as String);
        if (decoded is Map<String, dynamic>) {
          controller.add(NotificationRealtimeEvent.fromJson(decoded));
        }
      },
      onError: controller.addError,
      onDone: controller.close,
    );
    controller.onCancel = () async {
      await subscription.cancel();
      await channel.sink.close();
    };
    return controller.stream;
  }
}
