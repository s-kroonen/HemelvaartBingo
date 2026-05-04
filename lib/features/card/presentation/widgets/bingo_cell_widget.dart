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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cell.isChecked ? Colors.green : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
        ),
        child: Center(
          child: Text(
            cell.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: cell.value.length > 3 ? 12 : 18, // Shrink text if it's "FREE"
              fontWeight: FontWeight.bold,
              color: cell.isChecked ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }
}