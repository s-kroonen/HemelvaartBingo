// lib/core/router.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/providers/authState_provider.dart';
import '../features/invites/presentation/join_match_screen.dart';
import 'main_screen.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
// lib/core/router.dart

// lib/core/router.dart

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier(0);
  ref.listen(authStateProvider, (_, __) => notifier.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      // Check if they are on EITHER login or register
      final isAuthPath =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthPath) {
        final from = state.uri.toString();
        return '/login?from=${Uri.encodeComponent(from)}';
      }

      if (isLoggedIn && isAuthPath) {
        final from = state.uri.queryParameters['from'];
        return from != null ? Uri.decodeComponent(from) : '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/join/:token',
        builder: (context, state) {
          final token = state.pathParameters['token'] ?? "";
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
