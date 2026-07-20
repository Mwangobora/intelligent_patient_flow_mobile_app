import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/checkin_models.dart';

class CheckinApiService {
  const CheckinApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<CheckinEligibility> getEligibility(String appointmentId) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.checkins.patientEligibility,
      queryParameters: {'appointment_id': appointmentId},
    );
    return CheckinEligibility.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<AppointmentCheckinResult> checkInAppointment(
    String appointmentId,
  ) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.checkins.patientAppointmentCheckin(appointmentId),
    );
    return AppointmentCheckinResult.fromJson(
      response.data ?? <String, dynamic>{},
    );
  }
}
