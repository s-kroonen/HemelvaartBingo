// lib/core/router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/providers/authState_provider.dart';
import '../features/invites/presentation/join_match_screen.dart';
import 'main_screen.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
// lib/core/router.dart

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier(0);
  ref.listen(authStateProvider, (_, __) => notifier.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);

      return authAsync.when(
        data: (auth) {
          final isLoggedIn = auth.isLoggedIn;
          // Are we currently on the login page?
          final isLoggingIn = state.matchedLocation == '/login';

          if (!isLoggedIn) {
            // Not logged in? Go to login, but keep the current location in a query param
            // so we can return here after login.
            return isLoggingIn ? null : '/login?from=${state.uri.toString()}';
          }

          // If logged in and on login page, go to the intended destination or home
          if (isLoggingIn) {
            final from = state.uri.queryParameters['from'] ?? '/';
            return from;
          }

          return null;
        },
        loading: () => null,
        error: (_, __) => '/login',
      );
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