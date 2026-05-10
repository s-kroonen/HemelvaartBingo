// lib/core/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hemelvaartbingo/features/settings/settings_screen.dart';
import '../features/card/presentation/pages/card_page.dart';
import '../features/user/presentation/profile_screen.dart';
import '../services/notification.manager.dart';
import '../shared/providers/update_provider.dart';
import '../shared/widgets/main_navigation.dart';
import '../shared/widgets/themed_background.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the provider directly
      ref.read(notificationServiceProvider).checkPermissionOnStartup(context);
    });
  }

  final pages = const [
    ProfileScreen(),
    CardPage(),
    Center(child: Text("Leaderboard Page")),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final hasUpdate = ref.watch(updateProvider);
    return Scaffold(
      appBar: hasUpdate
          ? AppBar(
              backgroundColor: Colors.orangeAccent,
              title: const Text(
                "New Version Available!",
                style: TextStyle(fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      ref.read(updateProvider.notifier).activateUpdate(),
                  child: const Text(
                    "UPDATE NOW",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              toolbarHeight: 40,
            )
          : null,
      body: ThemedBackground(child: pages[currentIndex]),
      bottomNavigationBar: MainNavigation(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
