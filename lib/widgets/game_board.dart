// lib/widgets/game_board.dart

import 'package:flutter/material.dart';
import 'game_cell.dart';

class GameBoard extends StatelessWidget {
  final List<List<String>> board;
  final Function(int, int) onCellTap;
  final bool isPlayerTurn;
  final List<int>? hintCell;

  const GameBoard({
    Key? key,
    required this.board,
    required this.onCellTap,
    required this.isPlayerTurn,
    this.hintCell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1, // Keep it square
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final row = index ~/ 3;
            final col = index % 3;
            final cellValue = board[row][col];

            return _buildCell(row, col, cellValue);
          },
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col, String value) {
    final isHint =
        hintCell != null && hintCell![0] == row && hintCell![1] == col;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isHint ? Colors.yellow.shade100 : null,
        borderRadius: BorderRadius.circular(12),
        border: isHint
            ? Border.all(color: Colors.yellow.shade700, width: 3)
            : null,
      ),
      child: GameCell(
        value: value,
        onTap: () => onCellTap(row, col),
        isClickable: isPlayerTurn,
      ),
    );
  }
}
