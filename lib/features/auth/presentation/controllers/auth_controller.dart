import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_result.dart';
import '../../data/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, sessionError }

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
  bool _sessionCheckInFlight = false;

  Future<void> checkSession({bool force = false}) async {
    if (_sessionCheckInFlight) return;
    if (!force &&
        state.status != AuthStatus.unknown &&
        state.status != AuthStatus.sessionError) {
      return;
    }
    _sessionCheckInFlight = true;
    _logTransition('checking_session');
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.currentUser();
    switch (result) {
      case ApiSuccess(data: final user):
        _logTransition('authenticated');
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
      case ApiFailure(message: final message):
        final isUnauthorized = _isUnauthorizedSession(message);
        _logTransition(isUnauthorized ? 'unauthenticated' : 'session_error');
        state = state.copyWith(
          status: isUnauthorized
              ? AuthStatus.unauthenticated
              : AuthStatus.sessionError,
          errorMessage: message,
          isLoading: false,
          clearUser: true,
        );
    }
    _sessionCheckInFlight = false;
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _logTransition('login_submitted');
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    switch (result) {
      case ApiSuccess(data: final response):
        _logTransition('login_authenticated');
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
          isLoading: false,
        );
        return true;
      case ApiFailure(message: final message):
        _logTransition('login_failed');
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
    _logTransition('logout_submitted');
    state = state.copyWith(isLoading: true, clearError: true);
    await repository.logout();
    _logTransition('logged_out');
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

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    switch (result) {
      case ApiSuccess():
        state = state.copyWith(isLoading: false, clearError: true);
        return true;
      case ApiFailure(message: final message):
        state = state.copyWith(
          isLoading: false,
          errorMessage: _friendlyPasswordError(message),
        );
        return false;
    }
  }

  bool _isUnauthorizedSession(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('log in') ||
        normalized.contains('sign in') ||
        normalized.contains('authentication credentials') ||
        normalized.contains('unauthorized');
  }

  void _logTransition(String event) {
    if (kDebugMode) debugPrint('[auth] $event');
  }

  String _friendlyPasswordError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('old password') ||
        normalized.contains('incorrect')) {
      return 'Your current password is incorrect.';
    }
    if (normalized.contains('too short') ||
        normalized.contains('common') ||
        normalized.contains('numeric')) {
      return 'Please choose a stronger new password.';
    }
    return message;
  }
}
