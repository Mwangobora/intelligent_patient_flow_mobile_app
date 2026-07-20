import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/auth_response.dart';
import 'models/auth_user.dart';

class AuthApiService {
  const AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResponse> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.auth.login,
      data: {'email_or_phone': emailOrPhone, 'password': password},
    );
    return AuthResponse.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<AuthUser> currentUser() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.auth.me,
    );
    return AuthUser.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<AuthUser> updateCurrentUser({
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    final payload = <String, String>{};
    if (firstName != null) payload['first_name'] = firstName;
    if (middleName != null) payload['middle_name'] = middleName;
    if (lastName != null) payload['last_name'] = lastName;

    final response = await _apiClient.dio.patch<Map<String, dynamic>>(
      ApiEndpoints.auth.me,
      data: payload,
    );
    return AuthUser.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> logout() async {
    await _apiClient.dio.post<void>(ApiEndpoints.auth.logout, data: {});
    await _apiClient.clearSession();
  }
}
