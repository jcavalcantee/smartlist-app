import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/confirm_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/history/screens/history_detail_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/monthly_list/screens/monthly_list_screen.dart';
import '../../features/welcome/screens/welcome_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final publicRoutes = ['/', '/login', '/register', '/confirm'];
      if (publicRoutes.contains(state.matchedLocation)) return null;

      try {
        final session = await Amplify.Auth.fetchAuthSession();
        if (!session.isSignedIn) return '/';
      } catch (_) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/confirm',
        builder: (context, state) => ConfirmScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/list/:yearMonth',
        builder: (context, state) => MonthlyListScreen(
          yearMonth: state.pathParameters['yearMonth']!,
        ),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/history/:yearMonth',
        builder: (context, state) => HistoryDetailScreen(
          yearMonth: state.pathParameters['yearMonth']!,
        ),
      ),
    ],
  );
});
