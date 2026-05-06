// lib/features/card/presentation/widgets/bingo_cell_widget.dart

import 'package:flutter/material.dart';
import '../../data/card_model.dart';

class BingoCellWidget extends StatelessWidget {
  final CellModel cell;
  final VoidCallback onTap;

  const BingoCellWidget({
    super.key,
    required this.cell,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer( // Switched to AnimatedContainer for a smooth "check" effect
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // 1. If checked, use primary color with slight transparency
          // 2. If not checked, keep it transparent to show the SVG
          color: cell.isChecked
              ? colorScheme.primary.withAlpha(200)
              : colorScheme.surface.withAlpha(50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cell.isChecked
                ? colorScheme.primary
                : colorScheme.outlineVariant.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (cell.isChecked)
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: Text(
            cell.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: cell.value.length > 3 ? 12 : 18,
              fontWeight: FontWeight.bold,
              // Uses "onPrimary" for contrast when checked, otherwise theme text color
              color: cell.isChecked
                  ? colorScheme.onPrimary
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}