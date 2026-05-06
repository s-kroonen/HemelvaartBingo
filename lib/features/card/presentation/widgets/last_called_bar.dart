// lib/features/card/presentation/widgets/last_called_bar.dart

import 'package:flutter/material.dart';

class LastCalledBar extends StatelessWidget {
  final List<int> calledNumbers;

  const LastCalledBar({super.key, required this.calledNumbers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (calledNumbers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        color: colorScheme.surface.withOpacity(0.05), // Very subtle
        child: const Text(
          "Waiting for the Master to call a number...",
          style: TextStyle(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      );
    }

    final lastNumber = calledNumbers.last;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // Use a themed container color that lets the background peek through
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.7),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "LAST NUMBER",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  )
              ),
              Text(
                lastNumber.toString(),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary, // Uses the current Theme Style color (Green/Pink/Blue)
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: () {
              // TODO: Trigger Ad and show full list
            },
            icon: const Icon(Icons.history, size: 16),
            label: const Text("History"),
          )
        ],
      ),
    );
  }
}