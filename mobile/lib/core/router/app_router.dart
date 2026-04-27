import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/welcome/screens/welcome_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/monthly_list/screens/monthly_list_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/history/screens/history_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/list',
        builder: (context, state) => const MonthlyListScreen(),
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
