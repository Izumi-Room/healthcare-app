import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import '../features/quest/quest_screen.dart';
import '../features/reflection/reflection_screen.dart';
import '../features/sleep/sleep_screen.dart';
import '../features/stats/stats_screen.dart';
import '../main_scaffold.dart';
import '../features/auth/providers/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = authState.user != null;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // If not logged in and not on login/register, force redirect to /login
      if (!loggedIn && !loggingIn) return '/login';
      // If logged in and attempting to access login/register, send to /
      if (loggedIn && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/quests',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: QuestScreen()),
          ),
          GoRoute(
            path: '/sleep',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SleepScreen()),
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StatsScreen()),
          ),
          GoRoute(
            path: '/reflection',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReflectionScreen()),
          ),
        ],
      ),
    ],
  );
});
