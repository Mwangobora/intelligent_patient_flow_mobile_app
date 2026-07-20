import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/checkin_repository.dart';
import 'checkin_api_service.dart';
import 'models/checkin_models.dart';

class CheckinRepositoryImpl implements CheckinRepository {
  const CheckinRepositoryImpl(this._apiService);

  final CheckinApiService _apiService;

  @override
  Future<ApiResult<CheckinEligibility>> getEligibility(
    String appointmentId,
  ) async {
    try {
      return ApiResult.success(await _apiService.getEligibility(appointmentId));
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<AppointmentCheckinResult>> checkInAppointment(
    String appointmentId,
  ) async {
    try {
      return ApiResult.success(
        await _apiService.checkInAppointment(appointmentId),
      );
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<CheckinToken>> issueToken(String appointmentId) async {
    return const ApiResult.failure(
      'Patient QR token generation endpoint is not available yet.',
    );
  }
}
