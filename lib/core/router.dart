// lib/core/router.dart

import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/invites/presentation/join_match_screen.dart';
import 'main_screen.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
final routerProvider = Provider<GoRouter>((ref) {
  final authState = FirebaseAuth.instance.authStateChanges();

  return GoRouter(
    initialLocation: '/',
    // This allows the router to refresh whenever the user logs in/out
    refreshListenable: GoRouterRefreshStream(authState),
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // The Deep Link destination
      GoRoute(
        path: '/join/:token',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return JoinMatchScreen(token: token);
        },
      ),
    ],
  );
});

// Helper class to convert Stream to Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}