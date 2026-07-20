import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/json_list.dart';
import 'models/queue_models.dart';

class QueueApiService {
  const QueueApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<QueueEntry?> getCurrentQueue() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.queue.patientCurrent,
    );
    final data = response.data ?? <String, dynamic>{};
    if (data['queue_entry_id'] == null) return null;
    return QueueEntry.fromPatientJson(data);
  }

  Future<List<QueueEntry>> listQueueHistory() async {
    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.queue.patientHistory,
    );
    return asJsonList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(QueueEntry.fromPatientJson)
        .toList();
  }
}
