import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class ProfileApiService {
  const ProfileApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<dynamic>> listPatientProfiles() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      ApiEndpoints.profile.patients,
    );
    return response.data ?? <dynamic>[];
  }
}
