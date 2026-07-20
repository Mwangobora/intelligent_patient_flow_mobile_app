import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../features/appointments/presentation/screens/appointment_detail_screen.dart';
import '../features/appointments/presentation/screens/appointment_new_screen.dart';
import '../features/appointments/presentation/screens/appointments_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/checkin/presentation/screens/checkin_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/queue/presentation/screens/queue_screen.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';

class AppRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

GoRouter createAppRouter({
  required AuthState Function() authStateReader,
  required Listenable refreshListenable,
}) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = authStateReader();
      final location = state.uri.path;
      final isPublicAuthRoute = {'/login', '/register'}.contains(location);
      final isSessionRoute = {'/splash', '/onboarding'}.contains(location);

      if (authState.status == AuthStatus.unknown) {
        return location == '/splash' ? null : '/splash';
      }
      if (authState.status == AuthStatus.sessionError) {
        return location == '/splash' ? null : '/splash';
      }
      if (authState.status == AuthStatus.unauthenticated &&
          !isPublicAuthRoute) {
        return '/login';
      }
      if (authState.status == AuthStatus.authenticated &&
          (isPublicAuthRoute || isSessionRoute)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: '/appointments/new',
        builder: (context, state) => const AppointmentNewScreen(),
      ),
      GoRoute(
        path: '/appointments/:id',
        builder: (context, state) => AppointmentDetailScreen(
          appointmentId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/appointments/:id/reschedule',
        builder: (context, state) => AppointmentNewScreen(
          rescheduleAppointmentId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/checkin',
        builder: (context, state) => const CheckinScreen(),
      ),
      GoRoute(
        path: '/checkin/:appointmentId',
        builder: (context, state) =>
            CheckinScreen(appointmentId: state.pathParameters['appointmentId']),
      ),
      GoRoute(path: '/queue', builder: (context, state) => const QueueScreen()),
      GoRoute(
        path: '/queue/:queueEntryId',
        builder: (context, state) =>
            QueueScreen(queueEntryId: state.pathParameters['queueEntryId']),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
