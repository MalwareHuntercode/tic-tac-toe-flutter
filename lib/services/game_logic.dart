// lib/services/game_logic.dart

import 'dart:math';

/// This class handles all game logic
class GameLogic {
  // Check if someone won
  static String checkWinner(List<List<String>> board) {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != '' &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return board[i][0]; // Return 'X' or 'O'
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] != '' &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        return board[0][i]; // Return 'X' or 'O'
      }
    }

    // Check diagonals
    if (board[0][0] != '' &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return board[0][0];
    }

    if (board[0][2] != '' &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return board[0][2];
    }

    // No winner
    return '';
  }

  // Check if board is full (draw)
  static bool isBoardFull(List<List<String>> board) {
    for (var row in board) {
      for (var cell in row) {
        if (cell == '') return false;
      }
    }
    return true;
  }

  // Make app's move (random strategy)
  static List<int>? makeAppMove(List<List<String>> board) {
    List<List<int>> emptyCells = [];

    // Find all empty cells
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == '') {
          emptyCells.add([i, j]);
        }
      }
    }

    // If no empty cells, return null
    if (emptyCells.isEmpty) return null;

    // Pick a random empty cell
    final random = Random();
    return emptyCells[random.nextInt(emptyCells.length)];
  }
}
