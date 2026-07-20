import '../../../../core/network/api_result.dart';
import '../../data/models/appointment_models.dart';
import '../../data/models/booking_models.dart';

abstract interface class AppointmentsRepository {
  Future<ApiResult<List<Appointment>>> listAppointments({
    required String patientId,
    String? status,
    DateTime? startsFrom,
    DateTime? endsTo,
  });

  Future<ApiResult<Appointment>> getAppointment(String id);

  Future<ApiResult<List<AppointmentStatusEvent>>> getStatusHistory(String id);

  Future<ApiResult<Appointment>> createAppointment({
    required String patientId,
    required String facilityId,
    required String facilitySpecialtyId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? appointmentSlotId,
    String? reasonForVisit,
  });

  Future<ApiResult<Appointment>> cancelAppointment({
    required String appointmentId,
    required String reason,
  });

  Future<ApiResult<Appointment>> rescheduleAppointment({
    required String appointmentId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? appointmentSlotId,
    String? reasonForVisit,
  });

  Future<ApiResult<List<FacilityOption>>> listFacilities({
    String? organizationId,
  });

  Future<ApiResult<List<FacilitySpecialtyOption>>> listFacilitySpecialties({
    required String facilityId,
  });

  Future<ApiResult<List<AppointmentSlotOption>>> listAvailableSlots({
    required String facilityId,
    required String facilitySpecialtyId,
    required DateTime startsFrom,
    required DateTime endsTo,
  });
}
