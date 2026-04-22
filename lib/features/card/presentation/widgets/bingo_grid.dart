// lib/features/card/presentation/widgets/bingo_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../match/providers/match_provider.dart';
import '../../models/card_model.dart';
import 'bingo_cell_widget.dart';

class BingoGrid extends ConsumerWidget {
  final List<CellModel> cells;

  const BingoGrid({
    super.key,
    required this.cells,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate grid size based on cell count (e.g., 25 cells = 5x5)
    final gridSize = sqrt(cells.length).toInt();

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) {
        // Sort cells by position if the backend doesn't guarantee order
        final sortedCells = [...cells]..sort((a, b) => a.position.compareTo(b.position));
        final cell = sortedCells[index];

        return BingoCellWidget(
          cell: cell,
          onTap: () {
            // Use the notifier to send the update to NestJS
            ref.read(currentMatchProvider.notifier).toggleCellCheck(cell.id, !cell.isChecked);
          },
        );
      },
    );
  }
}