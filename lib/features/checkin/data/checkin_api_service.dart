import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/json_list.dart';
import 'models/checkin_models.dart';

class CheckinApiService {
  const CheckinApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PatientCheckin>> listCheckins({
    String? patientId,
    String? appointmentId,
    bool? isVoided,
  }) async {
    final queryParameters = <String, String>{};
    if (patientId != null) {
      queryParameters['patient_id'] = patientId;
    }
    if (appointmentId != null) {
      queryParameters['appointment_id'] = appointmentId;
    }
    if (isVoided != null) {
      queryParameters['is_voided'] = isVoided.toString();
    }

    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.checkins.base,
      queryParameters: queryParameters,
    );
    return asJsonList(
      response.data,
    ).whereType<Map<String, dynamic>>().map(PatientCheckin.fromJson).toList();
  }

  Future<PatientCheckin> createAppointmentCheckin({
    required String facilityId,
    required String patientId,
    required String appointmentId,
    String? facilitySpecialtyId,
  }) async {
    final data = <String, String>{
      'facility_id': facilityId,
      'patient_id': patientId,
      'appointment_id': appointmentId,
      'checkin_method': CheckinMethod.mobile,
    };
    if (facilitySpecialtyId != null) {
      data['facility_specialty_id'] = facilitySpecialtyId;
    }

    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.checkins.appointment,
      data: data,
    );
    return PatientCheckin.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<CheckinToken> issueToken(String appointmentId) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.checkins.tokenIssue,
      data: {'appointment_id': appointmentId},
    );
    return CheckinToken.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<List<CheckinToken>> listTokens(String appointmentId) async {
    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.checkins.tokens,
      queryParameters: {'appointment_id': appointmentId, 'only_active': 'true'},
    );
    return asJsonList(
      response.data,
    ).whereType<Map<String, dynamic>>().map(CheckinToken.fromJson).toList();
  }

  Future<PatientCheckin> consumeToken(String rawToken) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.checkins.tokenConsume,
      data: {'raw_token': rawToken},
    );
    return PatientCheckin.fromJson(response.data ?? <String, dynamic>{});
  }
}
