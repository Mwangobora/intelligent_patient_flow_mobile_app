import '../../../../core/network/api_result.dart';

abstract interface class AppointmentsRepository {
  Future<ApiResult<List<dynamic>>> listAppointments();
}
