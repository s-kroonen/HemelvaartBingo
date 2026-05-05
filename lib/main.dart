// main.dart
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:hemelvaartbingo/shared/providers/theme_provider.dart';
import 'package:hemelvaartbingo/shared/theme.dart';
import 'core/router.dart';
import 'firebase_options.dart';

void main() async {
  usePathUrlStrategy();
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
    if (kIsWeb) return;
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
      router.go('/join/$token');
    }
  }
  @override
  Widget build(BuildContext context) {
    // 1. Watch the full theme state (contains .mode and .style)
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'BingoVaart',

      // 2. Use the dynamic generator for Light Theme
      theme: AppThemes.createTheme(themeState, false),

      // 3. Use the dynamic generator for Dark Theme
      darkTheme: AppThemes.createTheme(themeState, true),

      // 4. Pass the mode (system, light, or dark)
      themeMode: themeState.mode,

      debugShowCheckedModeBanner: false,
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}
