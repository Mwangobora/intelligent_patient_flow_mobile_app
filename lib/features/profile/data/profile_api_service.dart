import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/patient_profile.dart';

class ProfileApiService {
  const ProfileApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PatientProfile>> listPatientProfiles({
    required String userId,
  }) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      ApiEndpoints.profile.patients,
      queryParameters: {'user_id': userId, 'is_active': true},
    );
    return (response.data ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(PatientProfile.fromJson)
        .toList();
  }
}
