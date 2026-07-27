import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/patient_profile.dart';

class ProfileApiService {
  const ProfileApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<PatientProfile> currentPatientProfile() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.profile.me,
    );
    return PatientProfile.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<PatientProfile> updateCurrentPatientProfile({
    String? email,
    String? phoneNumber,
  }) async {
    final response = await _apiClient.dio.patch<Map<String, dynamic>>(
      ApiEndpoints.profile.me,
      data: {'email': email, 'phone_number': phoneNumber},
    );
    return PatientProfile.fromJson(response.data ?? <String, dynamic>{});
  }
}
