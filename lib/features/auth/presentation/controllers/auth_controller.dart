import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_result.dart';
import '../../data/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
    this.isLoading = false,
    this.registrationSupported = false,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final bool isLoading;
  final bool registrationSupported;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    bool? isLoading,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      registrationSupported: registrationSupported,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({required this.repository}) : super(const AuthState());

  final AuthRepository repository;

  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.currentUser();
    switch (result) {
      case ApiSuccess(data: final user):
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
      case ApiFailure(message: final message):
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: message,
          isLoading: false,
          clearUser: true,
        );
    }
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    switch (result) {
      case ApiSuccess(data: final response):
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
          isLoading: false,
        );
        return true;
      case ApiFailure(message: final message):
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: message,
          isLoading: false,
          clearUser: true,
        );
        return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> updateProfile({
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.updateCurrentUser(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
    );
    switch (result) {
      case ApiSuccess(data: final user):
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
        return true;
      case ApiFailure(message: final message):
        state = state.copyWith(errorMessage: message, isLoading: false);
        return false;
    }
  }
}
