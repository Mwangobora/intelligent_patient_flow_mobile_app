import '../../../../core/network/api_result.dart';
import '../../data/models/checkin_models.dart';

abstract interface class CheckinRepository {
  Future<ApiResult<CheckinEligibility>> getEligibility(String appointmentId);

  Future<ApiResult<AppointmentCheckinResult>> checkInAppointment(
    String appointmentId,
  );

  Future<ApiResult<CheckinToken>> issueToken(String appointmentId);

  Future<ApiResult<AppointmentCheckinResult>> consumeQrToken(String token);
}
