// lib/shared/theme.dart
import 'package:flutter/material.dart';
import 'package:hemelvaartbingo/shared/providers/theme_provider.dart';

class AppThemes {
  static ThemeData createTheme(ThemeState themeState, bool isDark) {
    return ThemeData(
      useMaterial3: true,
      // The seed color now comes from the Style (Camping, Party, etc.)
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeState.style.seedColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),

      // Customize specific component themes here
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Global BottomNav styling based on the theme style
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: isDark ? Colors.yellowAccent : themeState.style.seedColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}