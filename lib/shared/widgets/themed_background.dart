// lib/shared/widgets/themed_background.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            child: _buildDecoration(context, themeStyle),
          ),
        ),

        // The actual content
        SafeArea(child: child),
      ],
    );
  }

  Widget _buildDecoration(BuildContext context, AppThemeStyle style) {
    // We use the theme's primary color to tint the SVG
    final Color tintColor = Theme.of(context).colorScheme.primary;

    switch (style) {
      case AppThemeStyle.camping:
        return SvgPicture.asset(
          'camping.svg',
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter, // Sits at the bottom of the screen
          colorFilter: ColorFilter.mode(
            tintColor.withAlpha(255),
            BlendMode.srcIn,
          ),
        );
      case AppThemeStyle.party:
        return SvgPicture.asset(
          'party.svg',
          fit: BoxFit.contain,
          alignment: Alignment.topRight,
          // Lights/decorations usually look better at the top
          colorFilter: ColorFilter.mode(tintColor, BlendMode.srcIn),
        );
      default:
        // For basic colors (Blue/Green styles), maybe just show a subtle gradient
        return const SizedBox.shrink();
    }
  }
}
