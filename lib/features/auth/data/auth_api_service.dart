import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class AuthApiService {
  const AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> currentUser() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.auth.me,
    );
    return response.data ?? <String, dynamic>{};
  }
}
