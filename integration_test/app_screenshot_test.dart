import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemelvaartbingo/features/auth/data/authState_model.dart';
import 'package:hemelvaartbingo/features/auth/providers/authState_provider.dart';
import 'package:hemelvaartbingo/features/event/data/event_model.dart';
import 'package:hemelvaartbingo/features/event/providers/event_provider.dart';
import 'package:hemelvaartbingo/features/match/data/match_models.dart';
import 'package:hemelvaartbingo/features/match/providers/match_provider.dart';
import 'package:hemelvaartbingo/features/user/data/user_model.dart';
import 'package:hemelvaartbingo/features/user/providers/user_provider.dart';
import 'package:hemelvaartbingo/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final testAuthLoggedInProvider = Provider<AuthState>((ref) {
  return const AuthState(isLoggedIn: true, userId: "demo-user");
});
final testAuthLoggedOutProvider = Provider<AuthState>((ref) {
  return const AuthState(isLoggedIn: false);
});

class DemoMatchNotifier extends CurrentMatchNotifier {
  @override
  Future<MatchContext> build() async {
    return MatchContext(
      match: MatchModel(
        id: "demo",
        calledNumbers: [12, 34, 56],
        name: "Demo Match",
        cardSize: 5,
        status: "active",
      ),
      roleInMatch: "player", // change to "master" for master test
    );
  }
}

class DemoUserProvider extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() async {
    return UserModel(
      id: "demo-user",
      score: 120,
      email: '',
      username: 'Demo User',
      roles: ["user"],
      awards: [],
      settings: UserSettings(
        emailNotifications: true,
        newsletter: false,
        testerProgram: false,
      ),
      // add required fields here
    );
  }
}

class DemoEventNotifier extends EventNotifier {
  @override
  Future<List<EventModel>> build() async {
    return [
      EventModel(
        id: "1",
        name: "This happened",
        called: true,
        numbers: [5, 10],
      ),
      EventModel(
        id: "2",
        name: "This didn't happen yet",
        called: false,
        numbers: [],
      ),
    ];
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding();
  // binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('Screenshot tests', () {
    testWidgets('Capture main pages', (tester) async {
      String platformName = '';

      if (!kIsWeb) {
        // Not required for the web. This is required prior to taking the screenshot.
        await binding.convertFlutterSurfaceToImage();

        if (Platform.isAndroid) {
          platformName = "android";
        } else {
          platformName = "ios";
        }
      } else {
        platformName = "web";
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // AUTH
            authStateProvider.overrideWith((ref) {
              return Stream.value(
                const AuthState(isLoggedIn: true, userId: "demo"),
              );
            }),

            // ✅ CURRENT MATCH (this drives card!)
            currentMatchProvider.overrideWith(DemoMatchNotifier.new),

            // ✅ EVENTS
            eventProvider.overrideWith(DemoEventNotifier.new),

            // ✅ USER (profile page)
            userProvider.overrideWith((ref) async {
              return UserModel(
                id: "demo-user",
                username: "Demo Player",
                score: 120,
                email: '',
                roles: [],
                awards: [],
                settings: UserSettings(
                  emailNotifications: true,
                  newsletter: false,
                  testerProgram: false,
                ),
              );
            }),

            // ✅ OPTIONAL: matches list (settings page)
            allMatchesProvider.overrideWith((ref) async {
              return [
                MatchModel(
                  id: "demo",
                  name: "Demo Match",
                  calledNumbers: [12, 34],
                  cardSize: 5,
                  status: "active",
                ),
              ];
            }),
          ],
          child: const MyApp(),
        ),
      );
      if (kDebugMode) {
        print("App pumped");
      }
      await tester.pumpAndSettle();
      if (kDebugMode) {
        print("Taking screenshot card");
      }
      // 📸 CARD PAGE
      await binding.takeScreenshot('01_card_page-$platformName');
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(seconds: 1));
      if (kDebugMode) {
        print("Taking screenshot settings");
      }
      // 📸 SETTINGS PAGE
      await binding.takeScreenshot('02_settings_page-$platformName');
      await tester.pump(const Duration(seconds: 2));

      // Navigate to profile (placeholder)
      await tester.tap(find.byIcon(Icons.person));
      await tester.pump(const Duration(seconds: 1));
      if (kDebugMode) {
        print("Taking screenshot profile");
      }
      // 📸 PROFILE PAGE
      await binding.takeScreenshot('03_profile_page-$platformName');
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
