import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class NotificationsApiService {
  const NotificationsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<dynamic>> listNotifications() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      ApiEndpoints.notifications.base,
    );
    return response.data ?? <dynamic>[];
  }
}
