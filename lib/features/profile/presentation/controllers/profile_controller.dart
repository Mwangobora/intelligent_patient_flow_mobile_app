import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_result.dart';
import '../../data/models/patient_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileState {
  const ProfileState({
    this.patientProfile,
    this.isLoading = false,
    this.errorMessage,
  });

  final PatientProfile? patientProfile;
  final bool isLoading;
  final String? errorMessage;

  List<PatientProfile> get patientProfiles {
    final profile = patientProfile;
    return profile == null ? const [] : [profile];
  }

  ProfileState copyWith({
    PatientProfile? patientProfile,
    bool? isLoading,
    String? errorMessage,
    bool clearProfile = false,
    bool clearError = false,
  }) {
    return ProfileState(
      patientProfile: clearProfile
          ? null
          : patientProfile ?? this.patientProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController({required this.repository}) : super(const ProfileState());

  final ProfileRepository repository;

  Future<void> loadCurrentPatientProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.currentProfile();
    switch (result) {
      case ApiSuccess(data: final profile):
        state = state.copyWith(patientProfile: profile, isLoading: false);
      case ApiFailure():
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Patient profile was not found for this mobile account yet.',
        );
    }
  }

  Future<void> loadLinkedPatientProfiles(String userId) async {
    await loadCurrentPatientProfile();
  }

  Future<bool> updateCurrentPatientProfile({
    String? email,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.updateCurrentProfile(
      email: email,
      phoneNumber: phoneNumber,
    );
    switch (result) {
      case ApiSuccess(data: final profile):
        state = state.copyWith(patientProfile: profile, isLoading: false);
        return true;
      case ApiFailure(message: final message):
        state = state.copyWith(isLoading: false, errorMessage: message);
        return false;
    }
  }
}
