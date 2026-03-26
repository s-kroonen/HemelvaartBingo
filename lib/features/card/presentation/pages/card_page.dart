// lib/features/card/presentation/pages/card_page.dart

import 'package:flutter/material.dart';
import '../widgets/bingo_grid.dart';
import '../widgets/event_list.dart';

class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMP mock data (replace later with API)
    final List<int> numbers = List.generate(25, (i) => i + 1); // 5x5
    final List<int> events = [43, 21, 7, 55, 12];

    return Scaffold(
      appBar: AppBar(title: const Text("Your Bingo Card")),
      body: Column(
        children: [
          // Bingo Grid
          Expanded(
            child: BingoGrid(
              numbers: numbers,
              gridSize: 5, // dynamic later
            ),
          ),
          const Divider(),
          // Event List
          SizedBox(height: 80, child: EventList(events: events)),
        ],
      ),
    );
  }
}
