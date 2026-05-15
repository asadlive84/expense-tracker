import 'package:expense_tracker_app/features/auth/providers/auth_controller.dart';
import 'package:expense_tracker_app/features/auth/screens/login_screen.dart';
import 'package:expense_tracker_app/features/auth/screens/register_screen.dart';
import 'package:expense_tracker_app/features/auth/screens/splash_screen.dart';
import 'package:expense_tracker_app/features/buckets/screens/buckets_screen.dart';
import 'package:expense_tracker_app/features/home/screens/home_screen.dart';
import 'package:expense_tracker_app/features/people/screens/people_screen.dart';
import 'package:expense_tracker_app/features/reminders/screens/reminders_screen.dart';
import 'package:expense_tracker_app/features/reports/screens/insights_screen.dart';
import 'package:expense_tracker_app/features/settings/screens/settings_screen.dart';
import 'package:expense_tracker_app/features/tags/screens/tags_screen.dart';
import 'package:expense_tracker_app/features/transactions/screens/ledger_screen.dart';
import 'package:expense_tracker_app/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouter = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isSplash = loc == '/splash';
      final isAuth = loc == '/login' || loc == '/register';

      if (authState is AuthInitial) return isSplash ? null : '/splash';
      if (authState is Unauthenticated) return isAuth ? null : '/login';
      if (authState is Authenticated && (isAuth || isSplash)) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Push-on-top routes (outside shell)
      GoRoute(path: '/buckets', builder: (_, __) => const BucketsScreen()),
      GoRoute(path: '/people', builder: (_, __) => const PeopleScreen()),
      GoRoute(path: '/tags', builder: (_, __) => const TagsScreen()),

      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/ledger', builder: (_, __) => const LedgerScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/insights', builder: (_, __) => const InsightsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/reminders', builder: (_, __) => const RemindersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
  );
});
