import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/checkin_repository.dart';
import 'checkin_api_service.dart';
import 'models/checkin_models.dart';

class CheckinRepositoryImpl implements CheckinRepository {
  const CheckinRepositoryImpl(this._apiService);

  final CheckinApiService _apiService;

  @override
  Future<ApiResult<List<PatientCheckin>>> listCheckins({
    String? patientId,
    String? appointmentId,
    bool? isVoided,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.listCheckins(
          patientId: patientId,
          appointmentId: appointmentId,
          isVoided: isVoided,
        ),
      );
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<PatientCheckin>> createAppointmentCheckin({
    required String facilityId,
    required String patientId,
    required String appointmentId,
    String? facilitySpecialtyId,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.createAppointmentCheckin(
          facilityId: facilityId,
          patientId: patientId,
          appointmentId: appointmentId,
          facilitySpecialtyId: facilitySpecialtyId,
        ),
      );
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<CheckinToken>> issueToken(String appointmentId) async {
    try {
      return ApiResult.success(await _apiService.issueToken(appointmentId));
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<List<CheckinToken>>> listTokens(String appointmentId) async {
    try {
      return ApiResult.success(await _apiService.listTokens(appointmentId));
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<PatientCheckin>> consumeToken(String rawToken) async {
    try {
      return ApiResult.success(await _apiService.consumeToken(rawToken));
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }
}
