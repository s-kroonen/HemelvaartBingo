import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    brightness: Brightness.light,
    useMaterial3: true,
  );

  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    brightness: Brightness.dark,
    useMaterial3: true,
  );
}