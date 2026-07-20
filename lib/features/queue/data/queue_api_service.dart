import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class QueueApiService {
  const QueueApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<dynamic>> listQueueEntries() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      ApiEndpoints.queue.entries,
    );
    return response.data ?? <dynamic>[];
  }
}
