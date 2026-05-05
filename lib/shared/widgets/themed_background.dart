// lib/shared/widgets/themed_background.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

class ThemedBackground extends ConsumerWidget {
  final Widget child;
  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeStyle = ref.watch(themeProvider).style;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base Color
        Container(color: Theme.of(context).scaffoldBackgroundColor),

        // Background Decorations
        Positioned.fill(
          child: Opacity(
            opacity: isDark ? 0.05 : 0.1, // Subtle for dark mode
            child: _buildDecoration(themeStyle),
          ),
        ),

        // The actual content
        SafeArea(child: child),
      ],
    );
  }

  Widget _buildDecoration(AppThemeStyle style) {
    switch (style) {
      case AppThemeStyle.camping:
        return const Icon(Icons.park, size: 300); // Replace with SVG images
      case AppThemeStyle.party:
        return const Icon(Icons.wb_twilight, size: 300); // Replace with SVG decorations
      default:
        return const SizedBox.shrink(); // No icons for basic color themes
    }
  }
}