import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/appointment_models.dart';
import 'models/booking_models.dart';

class AppointmentsApiService {
  const AppointmentsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Appointment>> listAppointments({
    required String patientId,
    String? status,
    DateTime? startsFrom,
    DateTime? endsTo,
  }) async {
    final queryParameters = <String, String>{'patient_id': patientId};
    if (status != null) queryParameters['status'] = status;
    if (startsFrom != null) {
      queryParameters['starts_from'] = startsFrom.toIso8601String();
    }
    if (endsTo != null) queryParameters['ends_to'] = endsTo.toIso8601String();

    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.appointments.base,
      queryParameters: queryParameters,
    );
    return _asList(
      response.data,
    ).whereType<Map<String, dynamic>>().map(Appointment.fromJson).toList();
  }

  Future<Appointment> getAppointment(String id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.appointments.detail(id),
    );
    return Appointment.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<List<AppointmentStatusEvent>> getStatusHistory(String id) async {
    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.appointments.statusHistory(id),
    );
    return _asList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(AppointmentStatusEvent.fromJson)
        .toList();
  }

  Future<Appointment> createAppointment({
    required String patientId,
    required String facilityId,
    required String facilitySpecialtyId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? appointmentSlotId,
    String? reasonForVisit,
  }) async {
    final data = <String, String>{
      'patient_id': patientId,
      'facility_id': facilityId,
      'facility_specialty_id': facilitySpecialtyId,
      'scheduled_start': scheduledStart.toIso8601String(),
      'scheduled_end': scheduledEnd.toIso8601String(),
      'booking_channel': 'mobile',
    };
    if (appointmentSlotId != null) {
      data['appointment_slot_id'] = appointmentSlotId;
    }
    if (reasonForVisit != null && reasonForVisit.trim().isNotEmpty) {
      data['reason_for_visit'] = reasonForVisit.trim();
    }

    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.appointments.base,
      data: data,
    );
    return Appointment.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Appointment> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.appointments.cancel(appointmentId),
      data: {'cancellation_reason': reason},
    );
    return Appointment.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Appointment> rescheduleAppointment({
    required String appointmentId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? appointmentSlotId,
    String? reasonForVisit,
  }) async {
    final data = <String, String>{
      'scheduled_start': scheduledStart.toIso8601String(),
      'scheduled_end': scheduledEnd.toIso8601String(),
      'booking_channel': 'mobile',
    };
    if (appointmentSlotId != null) {
      data['appointment_slot_id'] = appointmentSlotId;
    }
    if (reasonForVisit != null && reasonForVisit.trim().isNotEmpty) {
      data['reason_for_visit'] = reasonForVisit.trim();
    }

    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.appointments.reschedule(appointmentId),
      data: data,
    );
    return Appointment.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<List<FacilityOption>> listFacilities({String? organizationId}) async {
    final queryParameters = <String, String>{'is_active': 'true'};
    if (organizationId != null) {
      queryParameters['organization_id'] = organizationId;
    }

    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.facilities.facilities,
      queryParameters: queryParameters,
    );
    return _asList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(FacilityOption.fromJson)
        .where((facility) => facility.isActive)
        .toList();
  }

  Future<List<FacilitySpecialtyOption>> listFacilitySpecialties({
    required String facilityId,
  }) async {
    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.facilities.facilitySpecialties,
      queryParameters: {'facility_id': facilityId, 'is_active': 'true'},
    );
    return _asList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(FacilitySpecialtyOption.fromJson)
        .where(
          (specialty) => specialty.isActive && specialty.acceptsAppointments,
        )
        .toList();
  }

  Future<List<AppointmentSlotOption>> listAvailableSlots({
    required String facilityId,
    required String facilitySpecialtyId,
    required DateTime startsFrom,
    required DateTime endsTo,
  }) async {
    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.appointments.slots,
      queryParameters: {
        'facility_id': facilityId,
        'facility_specialty_id': facilitySpecialtyId,
        'starts_from': startsFrom.toIso8601String(),
        'ends_to': endsTo.toIso8601String(),
        'only_available': 'true',
      },
    );
    return _asList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(AppointmentSlotOption.fromJson)
        .where((slot) => slot.isBookable)
        .toList();
  }
}

List<dynamic> _asList(dynamic data) {
  if (data is List<dynamic>) return data;
  if (data is Map<String, dynamic> && data['results'] is List<dynamic>) {
    return data['results'] as List<dynamic>;
  }
  return <dynamic>[];
}
