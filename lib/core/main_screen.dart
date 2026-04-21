// lib/core/main_screen.dart

import 'package:flutter/material.dart';
import 'package:hemelvaartbingo/features/settings/settings_screen.dart';
import '../features/card/presentation/pages/card_page.dart';
import '../shared/widgets/main_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 1;

  final pages = const [
    Center(child: Text("Profile Page")),
    CardPage(),
    Center(child: Text("Leaderboard Page")),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: MainNavigation(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}
