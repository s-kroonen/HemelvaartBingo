import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
// lib/shared/providers/theme_provider.dart

enum AppThemeStyle {
  camping(Colors.green, Icons.terrain),
  party(Colors.pink, Icons.celebration),
  festival(Colors.orange, Icons.festival),
  blue(Colors.blue, Icons.water_drop),
  green(Colors.teal, Icons.grass);

  final Color seedColor;
  final IconData icon;
  const AppThemeStyle(this.seedColor, this.icon);
}

// Update your state to hold both
class ThemeState {
  final ThemeMode mode;
  final AppThemeStyle style;

  ThemeState({required this.mode, required this.style});
}

class ThemeNotifier extends Notifier<ThemeState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  ThemeState build() {
    // Note: build must be synchronous, use a default then load
    _loadTheme();
    return ThemeState(mode: ThemeMode.system, style: AppThemeStyle.camping);
  }

  Future<void> _loadTheme() async {
    final modeName = await _storage.read(key: 'themeMode');
    final styleName = await _storage.read(key: 'themeStyle');

    final mode = ThemeMode.values.firstWhere((e) => e.name == modeName, orElse: () => ThemeMode.system);
    final style = AppThemeStyle.values.firstWhere((e) => e.name == styleName, orElse: () => AppThemeStyle.camping);

    state = ThemeState(mode: mode, style: style);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = ThemeState(mode: mode, style: state.style);
    await _storage.write(key: 'themeMode', value: mode.name);
  }

  Future<void> setThemeStyle(AppThemeStyle style) async {
    state = ThemeState(mode: state.mode, style: style);
    await _storage.write(key: 'themeStyle', value: style.name);
  }
}