// main.dart
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hemelvaartbingo/shared/providers/theme_provider.dart';
import 'package:hemelvaartbingo/shared/theme.dart';
import 'core/router.dart';
import 'firebase_options.dart';

const bool kIsDemoMode = bool.fromEnvironment('DEMO_MODE');

void main() async {
  assert(() {
    if (kIsDemoMode) {
      debugPrint("⚠️ DEMO MODE ENABLED");
    }
    return true;
  }());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    // Handle links when app is running in background/foreground
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleNavigation(uri);
    });
  }

  void _handleNavigation(Uri uri) {
    final router = ref.read(routerProvider);
    if (uri.path.startsWith('/join/')) {
      final token = uri.pathSegments.last;
      router.push('/join/$token');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Family Bingo',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}