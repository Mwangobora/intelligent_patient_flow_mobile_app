import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class CheckinApiService {
  const CheckinApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> consumeToken(String token) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.checkins.tokenConsume,
      data: {'token': token},
    );
    return response.data ?? <String, dynamic>{};
  }
}
