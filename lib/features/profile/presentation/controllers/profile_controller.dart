import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_result.dart';
import '../../data/models/patient_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileState {
  const ProfileState({
    this.patientProfiles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<PatientProfile> patientProfiles;
  final bool isLoading;
  final String? errorMessage;

  ProfileState copyWith({
    List<PatientProfile>? patientProfiles,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      patientProfiles: patientProfiles ?? this.patientProfiles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController({required this.repository}) : super(const ProfileState());

  final ProfileRepository repository;

  Future<void> loadLinkedPatientProfiles(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.listProfiles(userId: userId);
    switch (result) {
      case ApiSuccess(data: final profiles):
        state = state.copyWith(patientProfiles: profiles, isLoading: false);
      case ApiFailure():
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'Patient profile access is not available for this mobile account yet.',
        );
    }
  }
}
