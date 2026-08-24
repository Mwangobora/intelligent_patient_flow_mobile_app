import 'dart:async';
import 'dart:convert';

import '../../../core/network/realtime_client.dart';
import 'models/queue_models.dart';

class QueueRealtimeEvent {
  const QueueRealtimeEvent({required this.type, this.event, this.queueEntry});

  final String type;
  final String? event;
  final QueueEntry? queueEntry;

  factory QueueRealtimeEvent.fromJson(Map<String, dynamic> json) {
    final queueEntryJson = json['queue_entry'];
    return QueueRealtimeEvent(
      type: json['type'] as String? ?? '',
      event: json['event'] as String?,
      queueEntry:
          queueEntryJson is Map<String, dynamic> &&
              queueEntryJson['queue_entry_id'] != null
          ? QueueEntry.fromPatientJson(queueEntryJson)
          : null,
    );
  }
}

class QueueRealtimeService {
  const QueueRealtimeService(this._realtimeClient);

  final RealtimeClient _realtimeClient;

  Future<Stream<QueueRealtimeEvent>> connect() async {
    final channel = await _realtimeClient.connect('/ws/patient/queue/');
    final controller = StreamController<QueueRealtimeEvent>.broadcast();
    late final StreamSubscription<dynamic> subscription;

    subscription = channel.stream.listen(
      (message) {
        final decoded = jsonDecode(message as String);
        if (decoded is Map<String, dynamic>) {
          controller.add(QueueRealtimeEvent.fromJson(decoded));
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
