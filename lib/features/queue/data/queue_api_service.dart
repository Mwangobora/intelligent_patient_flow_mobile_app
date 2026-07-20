import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/json_list.dart';
import 'models/queue_models.dart';

class QueueApiService {
  const QueueApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<QueueEntry>> listQueueEntries({
    String? patientId,
    String? patientCheckinId,
    bool? activeOnly,
  }) async {
    final queryParameters = <String, String>{};
    if (patientId != null) {
      queryParameters['patient_id'] = patientId;
    }
    if (patientCheckinId != null) {
      queryParameters['patient_checkin_id'] = patientCheckinId;
    }
    if (activeOnly != null) {
      queryParameters['active_only'] = activeOnly.toString();
    }

    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.queue.entries,
      queryParameters: queryParameters,
    );
    return asJsonList(
      response.data,
    ).whereType<Map<String, dynamic>>().map(QueueEntry.fromJson).toList();
  }

  Future<QueueEntry> getQueueEntry(String id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.queue.detail(id),
    );
    return QueueEntry.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<List<QueueEntryEvent>> listEvents(String queueEntryId) async {
    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.queue.events(queueEntryId),
    );
    return asJsonList(
      response.data,
    ).whereType<Map<String, dynamic>>().map(QueueEntryEvent.fromJson).toList();
  }

  Future<WaitTimePrediction?> getLatestPrediction(String queueEntryId) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.intelligence.latestPrediction(queueEntryId),
    );
    final data = response.data;
    if (data == null || data.isEmpty) return null;
    return WaitTimePrediction.fromJson(data);
  }
}
