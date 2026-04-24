import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemelvaartbingo/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Firebase.initializeApp();
  });
  group('Screenshot tests', () {
    testWidgets('Capture main pages', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 📸 CARD PAGE
      await binding.takeScreenshot('01_card_page');

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // 📸 SETTINGS PAGE
      await binding.takeScreenshot('02_settings_page');

      // Navigate to profile (placeholder)
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // 📸 PROFILE PAGE
      await binding.takeScreenshot('03_profile_page');
    });
  });
}