import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/appointments_repository.dart';
import 'appointments_api_service.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  const AppointmentsRepositoryImpl(this._apiService);

  final AppointmentsApiService _apiService;

  @override
  Future<ApiResult<List<dynamic>>> listAppointments() async {
    try {
      return ApiResult.success(await _apiService.listAppointments());
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }
}
