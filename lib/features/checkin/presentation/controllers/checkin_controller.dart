import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_result.dart';
import '../../../appointments/data/models/appointment_models.dart';
import '../../data/models/checkin_models.dart';
import '../../domain/repositories/checkin_repository.dart';

class CheckinState {
  const CheckinState({
    this.appointment,
    this.eligibility,
    this.checkins = const [],
    this.tokens = const [],
    this.issuedToken,
    this.isLoading = false,
    this.isActionLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  final Appointment? appointment;
  final CheckinEligibility? eligibility;
  final List<PatientCheckin> checkins;
  final List<CheckinToken> tokens;
  final CheckinToken? issuedToken;
  final bool isLoading;
  final bool isActionLoading;
  final String? successMessage;
  final String? errorMessage;

  PatientCheckin? get activeCheckin {
    if (eligibility?.existingCheckin != null) {
      return eligibility!.existingCheckin;
    }
    final active = checkins.where((checkin) => !checkin.isVoided).toList();
    return active.isEmpty ? null : active.first;
  }

  CheckinToken? get activeToken {
    final active = tokens.where((token) => token.canUse).toList();
    return active.isEmpty ? issuedToken : active.first;
  }

  bool get isCheckedIn => activeCheckin != null;
  bool get canCheckIn => eligibility?.canCheckIn ?? !isCheckedIn;
  String? get blockReason => eligibility?.reason;

  CheckinState copyWith({
    Appointment? appointment,
    CheckinEligibility? eligibility,
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
      eligibility: eligibility ?? this.eligibility,
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
    final result = await repository.getEligibility(appointment.id);
    switch (result) {
      case ApiSuccess(data: final eligibility):
        state = state.copyWith(
          eligibility: eligibility,
          checkins: [
            if (eligibility.existingCheckin != null)
              eligibility.existingCheckin!,
          ],
          isLoading: false,
        );
      case ApiFailure(message: final message):
        state = state.copyWith(
          isLoading: false,
          errorMessage: _friendlyCheckinError(message),
        );
    }
  }

  Future<bool> checkInNow() async {
    final appointment = state.appointment;
    if (appointment == null) return false;
    if (!state.canCheckIn) {
      state = state.copyWith(
        errorMessage: _friendlyBlockReason(state.blockReason),
        clearMessages: false,
      );
      return false;
    }
    state = state.copyWith(isActionLoading: true, clearMessages: true);
    final result = await repository.checkInAppointment(appointment.id);
    switch (result) {
      case ApiSuccess(data: final checkinResult):
        state = state.copyWith(
          checkins: [checkinResult.checkin, ...state.checkins],
          isActionLoading: false,
          successMessage: checkinResult.message,
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

  Future<bool> consumeQrToken(String token) async {
    if (token.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'This QR code is not valid.');
      return false;
    }
    state = state.copyWith(isActionLoading: true, clearMessages: true);
    final result = await repository.consumeQrToken(token.trim());
    switch (result) {
      case ApiSuccess(data: final checkinResult):
        state = state.copyWith(
          checkins: [checkinResult.checkin, ...state.checkins],
          isActionLoading: false,
          successMessage: checkinResult.message,
        );
        return true;
      case ApiFailure(message: final message):
        state = state.copyWith(
          isActionLoading: false,
          errorMessage: _friendlyQrError(message),
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

  String _friendlyQrError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('expired')) return 'This QR code has expired.';
    if (normalized.contains('already') || normalized.contains('used')) {
      return 'This QR code has already been used.';
    }
    if (normalized.contains('does not belong') ||
        normalized.contains('permission') ||
        normalized.contains('403')) {
      return 'This QR code does not belong to your account.';
    }
    if (normalized.contains('connect') || normalized.contains('server')) {
      return 'Could not connect to the server. Please try again.';
    }
    return 'This QR code is not valid.';
  }

  String _friendlyBlockReason(String? reason) {
    return switch (reason) {
      'too_early' => 'You cannot check in for this appointment yet.',
      'too_late' => 'This appointment check-in window has closed.',
      'already_checked_in' =>
        'You are already checked in for this appointment.',
      'appointment_cancelled' ||
      'appointment_completed' ||
      'appointment_no_show' ||
      'appointment_rescheduled' => 'This appointment cannot be checked in.',
      _ => 'Check-in failed. Please try again or contact reception.',
    };
  }
}
