import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_result.dart';
import '../../../appointments/data/models/appointment_models.dart';
import '../../data/models/checkin_models.dart';
import '../../domain/repositories/checkin_repository.dart';

class CheckinState {
  const CheckinState({
    this.appointment,
    this.checkins = const [],
    this.tokens = const [],
    this.issuedToken,
    this.isLoading = false,
    this.isActionLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  final Appointment? appointment;
  final List<PatientCheckin> checkins;
  final List<CheckinToken> tokens;
  final CheckinToken? issuedToken;
  final bool isLoading;
  final bool isActionLoading;
  final String? successMessage;
  final String? errorMessage;

  PatientCheckin? get activeCheckin {
    final active = checkins.where((checkin) => !checkin.isVoided).toList();
    return active.isEmpty ? null : active.first;
  }

  CheckinToken? get activeToken {
    final active = tokens.where((token) => token.canUse).toList();
    return active.isEmpty ? issuedToken : active.first;
  }

  bool get isCheckedIn => activeCheckin != null;

  CheckinState copyWith({
    Appointment? appointment,
    List<PatientCheckin>? checkins,
    List<CheckinToken>? tokens,
    CheckinToken? issuedToken,
    bool clearIssuedToken = false,
    bool? isLoading,
    bool? isActionLoading,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return CheckinState(
      appointment: appointment ?? this.appointment,
      checkins: checkins ?? this.checkins,
      tokens: tokens ?? this.tokens,
      issuedToken: clearIssuedToken ? null : issuedToken ?? this.issuedToken,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CheckinController extends StateNotifier<CheckinState> {
  CheckinController({required this.repository}) : super(const CheckinState());

  final CheckinRepository repository;

  Future<void> loadForAppointment(Appointment appointment) async {
    state = state.copyWith(
      appointment: appointment,
      isLoading: true,
      clearMessages: true,
      clearIssuedToken: true,
    );
    final checkinsResult = await repository.listCheckins(
      appointmentId: appointment.id,
      isVoided: false,
    );
    final tokensResult = await repository.listTokens(appointment.id);

    final checkins = checkinsResult is ApiSuccess<List<PatientCheckin>>
        ? checkinsResult.data
        : <PatientCheckin>[];
    final tokens = tokensResult is ApiSuccess<List<CheckinToken>>
        ? tokensResult.data
        : <CheckinToken>[];
    final error = checkinsResult is ApiFailure<List<PatientCheckin>>
        ? checkinsResult.message
        : null;

    state = state.copyWith(
      checkins: checkins,
      tokens: tokens,
      isLoading: false,
      errorMessage: error,
    );
  }

  Future<void> loadForPatient(String patientId) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    final result = await repository.listCheckins(
      patientId: patientId,
      isVoided: false,
    );
    switch (result) {
      case ApiSuccess(data: final checkins):
        state = state.copyWith(checkins: checkins, isLoading: false);
      case ApiFailure(message: final message):
        state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  Future<bool> checkInNow() async {
    final appointment = state.appointment;
    if (appointment == null) return false;
    state = state.copyWith(isActionLoading: true, clearMessages: true);
    final result = await repository.createAppointmentCheckin(
      facilityId: appointment.facilityId,
      patientId: appointment.patientId,
      appointmentId: appointment.id,
      facilitySpecialtyId: appointment.facilitySpecialtyId,
    );
    switch (result) {
      case ApiSuccess(data: final checkin):
        state = state.copyWith(
          checkins: [checkin, ...state.checkins],
          isActionLoading: false,
          successMessage: 'Check-in successful.',
        );
        return true;
      case ApiFailure(message: final message):
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: _friendlyCheckinError(message),
        );
        return false;
    }
  }

  Future<bool> issueQrToken() async {
    final appointment = state.appointment;
    if (appointment == null) return false;
    state = state.copyWith(isActionLoading: true, clearMessages: true);
    final result = await repository.issueToken(appointment.id);
    switch (result) {
      case ApiSuccess(data: final token):
        state = state.copyWith(
          issuedToken: token,
          tokens: [token, ...state.tokens.where((item) => item.id != token.id)],
          isActionLoading: false,
          successMessage: 'QR code is ready.',
        );
        return true;
      case ApiFailure(message: final message):
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: _friendlyCheckinError(message),
        );
        return false;
    }
  }

  String _friendlyCheckinError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('too early') || normalized.contains('not open')) {
      return 'You cannot check in for this appointment yet.';
    }
    if (normalized.contains('cancelled') ||
        normalized.contains('completed') ||
        normalized.contains('no_show')) {
      return 'This appointment cannot be checked in.';
    }
    if (normalized.contains('duplicate') || normalized.contains('already')) {
      return 'You are already checked in for this appointment.';
    }
    if (normalized.contains('connect') || normalized.contains('server')) {
      return 'Could not connect to the server. Please try again.';
    }
    return 'Check-in failed. Please try again or contact reception.';
  }
}
