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

  Future<AuthResponse> register({
    required String firstName,
    String? middleName,
    required String lastName,
    String? dateOfBirth,
    bool dateOfBirthIsEstimated = false,
    String? sexCode,
    String? email,
    String? phoneNumber,
    required String password,
    required String passwordConfirm,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.auth.register,
      data: {
        'first_name': firstName,
        'middle_name': middleName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth,
        'date_of_birth_is_estimated': dateOfBirthIsEstimated,
        'sex_code': sexCode,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'password_confirm': passwordConfirm,
      },
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

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiClient.dio.post<void>(
      ApiEndpoints.auth.changePassword,
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }

  Future<void> logout() async {
    await _apiClient.dio.post<void>(ApiEndpoints.auth.logout, data: {});
    await _apiClient.clearSession();
  }
}
