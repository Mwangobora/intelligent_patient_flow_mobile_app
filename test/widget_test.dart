import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intelligent_patient_mobile_app/app/app.dart';
import 'package:intelligent_patient_mobile_app/app/app_providers.dart';
import 'package:intelligent_patient_mobile_app/core/network/api_result.dart';
import 'package:intelligent_patient_mobile_app/features/auth/data/models/auth_response.dart';
import 'package:intelligent_patient_mobile_app/features/auth/data/models/auth_user.dart';
import 'package:intelligent_patient_mobile_app/features/auth/domain/repositories/auth_repository.dart';

void main() {
  testWidgets('renders patient app shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: const PatientFlowApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<AuthUser>> currentUser() async {
    return const ApiResult.failure('No active test session.');
  }

  @override
  Future<ApiResult<AuthResponse>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    return const ApiResult.failure('Login is not used in this test.');
  }

  @override
  Future<ApiResult<void>> logout() async {
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<AuthUser>> updateCurrentUser({
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    return const ApiResult.failure('Profile update is not used in this test.');
  }
}
