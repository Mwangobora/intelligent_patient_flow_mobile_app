import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import 'models/appointment_models.dart';
import 'models/booking_models.dart';
import '../domain/repositories/appointments_repository.dart';
import 'appointments_api_service.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  const AppointmentsRepositoryImpl(this._apiService);

  final AppointmentsApiService _apiService;

  @override
  Future<ApiResult<List<Appointment>>> listAppointments({
    required String patientId,
    String? status,
    DateTime? startsFrom,
    DateTime? endsTo,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.listAppointments(
          patientId: patientId,
          status: status,
          startsFrom: startsFrom,
          endsTo: endsTo,
        ),
      );
    } catch (error) {
      return ApiResult.failure(_friendlyMessage(error));
    }
  }

  @override
  Future<ApiResult<Appointment>> getAppointment(String id) async {
    try {
      return ApiResult.success(await _apiService.getAppointment(id));
    } catch (error) {
      return ApiResult.failure(_friendlyMessage(error));
    }
  }

  @override
  Future<ApiResult<List<AppointmentStatusEvent>>> getStatusHistory(
    String id,
  ) async {
    try {
      return ApiResult.success(await _apiService.getStatusHistory(id));
    } catch (error) {
      return ApiResult.failure(_friendlyMessage(error));
    }
  }

  @override
  Future<ApiResult<Appointment>> createAppointment({
    required String patientId,
    required String facilityId,
    required String facilitySpecialtyId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? appointmentSlotId,
    String? reasonForVisit,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.createAppointment(
          patientId: patientId,
          facilityId: facilityId,
          facilitySpecialtyId: facilitySpecialtyId,
          scheduledStart: scheduledStart,
          scheduledEnd: scheduledEnd,
          appointmentSlotId: appointmentSlotId,
          reasonForVisit: reasonForVisit,
        ),
      );
    } catch (error) {
      return ApiResult.failure(_friendlyMessage(error));
    }
  }

  @override
  Future<ApiResult<Appointment>> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.cancelAppointment(
          appointmentId: appointmentId,
          reason: reason,
        ),
      );
    } catch (error) {
      return ApiResult.failure(_friendlyMessage(error));
    }
  }

  @override
  Future<ApiResult<Appointment>> rescheduleAppointment({
    required String appointmentId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? appointmentSlotId,
    String? reasonForVisit,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.rescheduleAppointment(
          appointmentId: appointmentId,
          scheduledStart: scheduledStart,
          scheduledEnd: scheduledEnd,
          appointmentSlotId: appointmentSlotId,
          reasonForVisit: reasonForVisit,
        ),
      );
    } catch (error) {
      return ApiResult.failure(_friendlyMessage(error));
    }
  }

  @override
  Future<ApiResult<List<FacilityOption>>> listFacilities({
    String? organizationId,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.listFacilities(organizationId: organizationId),
      );
    } catch (error) {
      return ApiResult.failure(_friendlyMessage(error));
    }
  }

  @override
  Future<ApiResult<List<FacilitySpecialtyOption>>> listFacilitySpecialties({
    required String facilityId,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.listFacilitySpecialties(facilityId: facilityId),
      );
    } catch (error) {
      return ApiResult.failure(_friendlyMessage(error));
    }
  }

  @override
  Future<ApiResult<List<AppointmentSlotOption>>> listAvailableSlots({
    required String facilityId,
    required String facilitySpecialtyId,
    required DateTime startsFrom,
    required DateTime endsTo,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.listAvailableSlots(
          facilityId: facilityId,
          facilitySpecialtyId: facilitySpecialtyId,
          startsFrom: startsFrom,
          endsTo: endsTo,
        ),
      );
    } catch (error) {
      return ApiResult.failure(_friendlyMessage(error));
    }
  }

  String _friendlyMessage(Object error) {
    final message = ErrorMapper.fromObject(error).message;
    final lower = message.toLowerCase();
    if (lower.contains('slot') && lower.contains('full')) {
      return 'This appointment slot is already full.';
    }
    if (lower.contains('overlap') || lower.contains('overlapping')) {
      return 'You already have an appointment at this time.';
    }
    if (lower.contains('not available') || lower.contains('availability')) {
      return 'This doctor is not available at the selected time.';
    }
    if (lower.contains('cancel')) {
      return 'This appointment cannot be cancelled right now.';
    }
    if (lower.contains('reschedule')) {
      return 'This appointment cannot be rescheduled right now.';
    }
    return message;
  }
}
