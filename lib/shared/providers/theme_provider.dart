import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _key = 'themeMode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system; // initial value
  }

  Future<void> _loadTheme() async {
    final value = await _storage.read(key: _key);

    if (value == 'light') {
      state = ThemeMode.light;
    } else if (value == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _storage.write(key: _key, value: mode.name);
  }
}