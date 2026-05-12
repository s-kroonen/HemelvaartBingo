// lib/features/notifications/notification_provider.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/user/providers/user_provider.dart';

final notificationServiceProvider = Provider((ref) => NotificationService(ref));

class NotificationService {
  final Ref ref;
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  NotificationService(this.ref);

  Future<void> checkPermissionOnStartup(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool? hasDismissed = prefs.getBool('fcm_prompt_dismissed');

    NotificationSettings settings = await _fcm.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined &&
        hasDismissed != true) {
      _showPermissionDialog(context);
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      registerToken();
    }
    // Inside your NotificationService initialization
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');

      if (message.notification != null) {
        // Show a SnackBar or a custom Dialog since the OS won't show a popup
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${message.notification!.title}: ${message.notification!.body}"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Stay Updated!"),
        content: const Text(
          "Get notified immediately when a new Bingo number is called.",
        ),
        actions: [
          TextButton(
            child: const Text("Later"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('fcm_prompt_dismissed', true);
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: const Text("Enable"),
            onPressed: () {
              Navigator.pop(context);
              requestAndRegister();
            },
          ),
        ],
      ),
    );
  }

  Future<void> requestAndRegister() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await registerToken();
    }
  }

  Future<void> registerToken() async {
    String? token = await _fcm.getToken(
      vapidKey:
          "BIRdR4wrFKibwpyfCU1QDdLZCJKpiKJwODQrSBYc8uuemBeyaREmXl8FnLVvV9LkD4q8pCec8HNCw8xfkm7vVqk",
    );

    if (token != null) {
      await ref.read(userServiceProvider).addUserTokens(token);
    }
  }
}
