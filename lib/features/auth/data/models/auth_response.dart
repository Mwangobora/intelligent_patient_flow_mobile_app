import 'auth_user.dart';

class AuthResponse {
  const AuthResponse({required this.user});

  final AuthUser user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? json),
    );
  }
}
