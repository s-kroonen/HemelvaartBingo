// lib/features/card/presentation/widgets/bingo_grid.dart

import 'package:flutter/material.dart';
import 'bingo_cell.dart';

class BingoGrid extends StatefulWidget {
  final List<int> numbers;
  final int gridSize;

  const BingoGrid({
    super.key,
    required this.numbers,
    required this.gridSize,
  });

  @override
  State<BingoGrid> createState() => _BingoGridState();
}

class _BingoGridState extends State<BingoGrid> {
  final Set<int> selectedNumbers = {};

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridSize,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.numbers.length,
      itemBuilder: (context, index) {
        final number = widget.numbers[index];
        final isSelected = selectedNumbers.contains(number);

        return BingoCell(
          number: number,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedNumbers.remove(number);
              } else {
                selectedNumbers.add(number);
              }
            });
          },
        );
      },
    );
  }
}