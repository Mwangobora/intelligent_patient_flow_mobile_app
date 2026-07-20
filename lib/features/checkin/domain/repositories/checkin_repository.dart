import '../../../../core/network/api_result.dart';
import '../../data/models/checkin_models.dart';

abstract interface class CheckinRepository {
  Future<ApiResult<List<PatientCheckin>>> listCheckins({
    String? patientId,
    String? appointmentId,
    bool? isVoided,
  });

  Future<ApiResult<PatientCheckin>> createAppointmentCheckin({
    required String facilityId,
    required String patientId,
    required String appointmentId,
    String? facilitySpecialtyId,
  });

  Future<ApiResult<CheckinToken>> issueToken(String appointmentId);

  Future<ApiResult<List<CheckinToken>>> listTokens(String appointmentId);

  Future<ApiResult<PatientCheckin>> consumeToken(String rawToken);
}
