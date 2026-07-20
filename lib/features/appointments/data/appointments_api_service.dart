import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class AppointmentsApiService {
  const AppointmentsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<dynamic>> listAppointments() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      ApiEndpoints.appointments.base,
    );
    return response.data ?? <dynamic>[];
  }
}
