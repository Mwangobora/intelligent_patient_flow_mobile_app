import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_result.dart';
import '../../data/models/appointment_models.dart';
import '../../data/models/booking_models.dart';
import '../../domain/repositories/appointments_repository.dart';

enum AppointmentFilter { upcoming, past, cancelled }

class AppointmentsState {
  const AppointmentsState({
    this.appointments = const [],
    this.filter = AppointmentFilter.upcoming,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Appointment> appointments;
  final AppointmentFilter filter;
  final bool isLoading;
  final String? errorMessage;

  List<Appointment> get visibleAppointments {
    final now = DateTime.now();
    return appointments.where((appointment) {
      if (filter == AppointmentFilter.cancelled) {
        return appointment.status == AppointmentStatus.cancelled;
      }
      if (filter == AppointmentFilter.past) {
        return appointment.isPast ||
            {
              AppointmentStatus.completed,
              AppointmentStatus.noShow,
              AppointmentStatus.rescheduled,
            }.contains(appointment.status);
      }
      return appointment.scheduledEnd.isAfter(now) &&
          appointment.status != AppointmentStatus.cancelled;
    }).toList();
  }

  Appointment? get nextAppointment {
    final upcoming =
        appointments
            .where(
              (appointment) =>
                  appointment.scheduledEnd.isAfter(DateTime.now()) &&
                  !AppointmentStatus.terminal.contains(appointment.status),
            )
            .toList()
          ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  AppointmentsState copyWith({
    List<Appointment>? appointments,
    AppointmentFilter? filter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppointmentsState(
      appointments: appointments ?? this.appointments,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AppointmentsController extends StateNotifier<AppointmentsState> {
  AppointmentsController({required this.repository})
    : super(const AppointmentsState());

  final AppointmentsRepository repository;

  Future<void> loadAppointments(String patientId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.listAppointments(patientId: patientId);
    switch (result) {
      case ApiSuccess(data: final appointments):
        state = state.copyWith(
          appointments: appointments,
          isLoading: false,
          clearError: true,
        );
      case ApiFailure(message: final message):
        state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  void setFilter(AppointmentFilter filter) {
    state = state.copyWith(filter: filter);
  }
}

class AppointmentDetailState {
  const AppointmentDetailState({
    this.appointment,
    this.history = const [],
    this.isLoading = false,
    this.isActionLoading = false,
    this.errorMessage,
  });

  final Appointment? appointment;
  final List<AppointmentStatusEvent> history;
  final bool isLoading;
  final bool isActionLoading;
  final String? errorMessage;

  AppointmentDetailState copyWith({
    Appointment? appointment,
    List<AppointmentStatusEvent>? history,
    bool? isLoading,
    bool? isActionLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppointmentDetailState(
      appointment: appointment ?? this.appointment,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AppointmentDetailController
    extends StateNotifier<AppointmentDetailState> {
  AppointmentDetailController({required this.repository})
    : super(const AppointmentDetailState());

  final AppointmentsRepository repository;

  Future<void> loadAppointment(String appointmentId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final appointmentResult = await repository.getAppointment(appointmentId);
    switch (appointmentResult) {
      case ApiSuccess(data: final appointment):
        final historyResult = await repository.getStatusHistory(appointmentId);
        state = state.copyWith(
          appointment: appointment,
          history: historyResult is ApiSuccess<List<AppointmentStatusEvent>>
              ? historyResult.data
              : state.history,
          isLoading: false,
          clearError: true,
        );
      case ApiFailure(message: final message):
        state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  Future<bool> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    final result = await repository.cancelAppointment(
      appointmentId: appointmentId,
      reason: reason,
    );
    switch (result) {
      case ApiSuccess(data: final appointment):
        state = state.copyWith(
          appointment: appointment,
          isActionLoading: false,
          clearError: true,
        );
        await loadAppointment(appointment.id);
        return true;
      case ApiFailure(message: final message):
        state = state.copyWith(isActionLoading: false, errorMessage: message);
        return false;
    }
  }
}

class BookingState {
  const BookingState({
    this.facilities = const [],
    this.specialties = const [],
    this.slots = const [],
    this.selectedFacility,
    this.selectedSpecialty,
    this.selectedDate,
    this.selectedSlot,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<FacilityOption> facilities;
  final List<FacilitySpecialtyOption> specialties;
  final List<AppointmentSlotOption> slots;
  final FacilityOption? selectedFacility;
  final FacilitySpecialtyOption? selectedSpecialty;
  final DateTime? selectedDate;
  final AppointmentSlotOption? selectedSlot;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  BookingState copyWith({
    List<FacilityOption>? facilities,
    List<FacilitySpecialtyOption>? specialties,
    List<AppointmentSlotOption>? slots,
    FacilityOption? selectedFacility,
    FacilitySpecialtyOption? selectedSpecialty,
    DateTime? selectedDate,
    AppointmentSlotOption? selectedSlot,
    bool clearFacility = false,
    bool clearSpecialty = false,
    bool clearDate = false,
    bool clearSlot = false,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingState(
      facilities: facilities ?? this.facilities,
      specialties: specialties ?? this.specialties,
      slots: slots ?? this.slots,
      selectedFacility: clearFacility
          ? null
          : selectedFacility ?? this.selectedFacility,
      selectedSpecialty: clearSpecialty
          ? null
          : selectedSpecialty ?? this.selectedSpecialty,
      selectedDate: clearDate ? null : selectedDate ?? this.selectedDate,
      selectedSlot: clearSlot ? null : selectedSlot ?? this.selectedSlot,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class BookingController extends StateNotifier<BookingState> {
  BookingController({required this.repository}) : super(const BookingState());

  final AppointmentsRepository repository;

  Future<void> loadFacilities({String? organizationId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.listFacilities(
      organizationId: organizationId,
    );
    switch (result) {
      case ApiSuccess(data: final facilities):
        state = state.copyWith(facilities: facilities, isLoading: false);
      case ApiFailure(message: final message):
        state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  Future<void> selectFacility(FacilityOption facility) async {
    state = state.copyWith(
      selectedFacility: facility,
      specialties: const [],
      slots: const [],
      clearSpecialty: true,
      clearSlot: true,
      clearError: true,
    );
    final result = await repository.listFacilitySpecialties(
      facilityId: facility.id,
    );
    switch (result) {
      case ApiSuccess(data: final specialties):
        state = state.copyWith(specialties: specialties);
      case ApiFailure(message: final message):
        state = state.copyWith(errorMessage: message);
    }
  }

  Future<void> selectSpecialty(FacilitySpecialtyOption specialty) async {
    state = state.copyWith(
      selectedSpecialty: specialty,
      slots: const [],
      clearSlot: true,
      clearError: true,
    );
    await _loadSlotsIfReady();
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(
      selectedDate: date,
      slots: const [],
      clearSlot: true,
    );
    await _loadSlotsIfReady();
  }

  Future<void> prepareReschedule(Appointment appointment) async {
    final facility = FacilityOption(
      id: appointment.facilityId,
      name: appointment.facilityName ?? 'Selected facility',
      code: '',
      organizationId: '',
      isActive: true,
    );
    state = state.copyWith(
      selectedFacility: facility,
      specialties: const [],
      slots: const [],
      clearSpecialty: true,
      clearSlot: true,
      clearError: true,
    );
    final result = await repository.listFacilitySpecialties(
      facilityId: appointment.facilityId,
    );
    switch (result) {
      case ApiSuccess(data: final specialties):
        FacilitySpecialtyOption? matching;
        for (final item in specialties) {
          if (item.id == appointment.facilitySpecialtyId) {
            matching = item;
            break;
          }
        }
        state = state.copyWith(
          specialties: specialties,
          selectedSpecialty: matching,
        );
        await _loadSlotsIfReady();
      case ApiFailure(message: final message):
        state = state.copyWith(errorMessage: message);
    }
  }

  void selectSlot(AppointmentSlotOption slot) {
    state = state.copyWith(selectedSlot: slot, clearError: true);
  }

  Future<Appointment?> submitBooking({
    required String patientId,
    String? reasonForVisit,
  }) async {
    final facility = state.selectedFacility;
    final specialty = state.selectedSpecialty;
    final slot = state.selectedSlot;
    if (facility == null || specialty == null || slot == null) {
      state = state.copyWith(
        errorMessage: 'Please select a facility, service, date, and slot.',
      );
      return null;
    }
    state = state.copyWith(isSubmitting: true, clearError: true);
    final result = await repository.createAppointment(
      patientId: patientId,
      facilityId: facility.id,
      facilitySpecialtyId: specialty.id,
      scheduledStart: slot.startsAt,
      scheduledEnd: slot.endsAt,
      appointmentSlotId: slot.id,
      reasonForVisit: reasonForVisit,
    );
    switch (result) {
      case ApiSuccess(data: final appointment):
        state = state.copyWith(isSubmitting: false);
        return appointment;
      case ApiFailure(message: final message):
        state = state.copyWith(isSubmitting: false, errorMessage: message);
        return null;
    }
  }

  Future<Appointment?> submitReschedule({
    required String appointmentId,
    String? reasonForVisit,
  }) async {
    final slot = state.selectedSlot;
    if (slot == null) {
      state = state.copyWith(errorMessage: 'Please select a new slot.');
      return null;
    }
    state = state.copyWith(isSubmitting: true, clearError: true);
    final result = await repository.rescheduleAppointment(
      appointmentId: appointmentId,
      scheduledStart: slot.startsAt,
      scheduledEnd: slot.endsAt,
      appointmentSlotId: slot.id,
      reasonForVisit: reasonForVisit,
    );
    switch (result) {
      case ApiSuccess(data: final appointment):
        state = state.copyWith(isSubmitting: false);
        return appointment;
      case ApiFailure(message: final message):
        state = state.copyWith(isSubmitting: false, errorMessage: message);
        return null;
    }
  }

  Future<void> _loadSlotsIfReady() async {
    final facility = state.selectedFacility;
    final specialty = state.selectedSpecialty;
    final date = state.selectedDate;
    if (facility == null || specialty == null || date == null) return;

    final startsFrom = DateTime(date.year, date.month, date.day);
    final endsTo = startsFrom.add(const Duration(days: 1));
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.listAvailableSlots(
      facilityId: facility.id,
      facilitySpecialtyId: specialty.id,
      startsFrom: startsFrom,
      endsTo: endsTo,
    );
    switch (result) {
      case ApiSuccess(data: final slots):
        state = state.copyWith(slots: slots, isLoading: false);
      case ApiFailure(message: final message):
        state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }
}
