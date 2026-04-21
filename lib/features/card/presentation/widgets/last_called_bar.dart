// lib/features/card/presentation/widgets/last_called_bar.dart

import 'package:flutter/material.dart';

class LastCalledBar extends StatelessWidget {
  final List<int> calledNumbers;

  const LastCalledBar({super.key, required this.calledNumbers});

  @override
  Widget build(BuildContext context) {
    if (calledNumbers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Waiting for the Master to call a number..."),
      );
    }

    final lastNumber = calledNumbers.last;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.blueGrey.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("LAST NUMBER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              Text(
                lastNumber.toString(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.normal, color: Colors.blue),
              ),
            ],
          ),
          // Placeholder for the "Show History" / Ad button
          TextButton.icon(
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