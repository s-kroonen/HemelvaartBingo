// lib/features/card/presentation/pages/card_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../match/data/match_models.dart';
import '../../../match/providers/match_provider.dart';
import '../widgets/bingo_grid.dart';
import '../widgets/last_called_bar.dart';

class CardPage extends ConsumerWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(currentMatchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Game Session")),
      body: contextAsync.when(
        data: (data) {
          // ROLE-BASED UI
          if (data.roleInMatch == "master") {
            return _buildMasterView(data);
          } else {
            return _buildPlayerView(data, ref);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) {
          if (kDebugMode) {
            print(e);
            print(stack);
          }

          return Center(child: Text("Error: $e"));
        },
      ),
    );
  }

  Widget _buildMasterView(MatchContext data) {
    final lastCalled = data.match.calledNumbers.isEmpty
        ? "?"
        : data.match.calledNumbers.last;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "BINGO MASTER MODE",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Text(
          lastCalled.toString(),
          style: const TextStyle(fontSize: 80, color: Colors.orange),
        ),
        ElevatedButton(
          onPressed: () => {/* Trigger API call to generate number */},
          child: const Text("CALL NEXT NUMBER"),
        ),
      ],
    );
  }

  Widget _buildPlayerView(MatchContext data, WidgetRef ref) {
    final cells = data.cells;

    if (cells == null) {
      return const Center(child: Text("No card available for this match"));
    }

    return Column(
      children: [
        LastCalledBar(calledNumbers: data.match.calledNumbers),
        Expanded(child: BingoGrid(cells: cells)),
      ],
    );
  }
}
