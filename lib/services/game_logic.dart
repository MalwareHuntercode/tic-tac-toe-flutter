// lib/services/game_logic.dart

import 'dart:math';
import 'dart:math' as math;

/// This class handles all game logic
class GameLogic {
  // All possible winning combinations
  static const List<List<int>> winningCombinations = [
    // Rows
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    // Columns
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    // Diagonals
    [0, 4, 8],
    [2, 4, 6],
  ];

  // Check if someone won
  static String checkWinner(List<List<String>> board) {
    // Flatten the board for easier checking
    final flatBoard = board.expand((row) => row).toList();

    // Check each winning combination
    for (final combination in winningCombinations) {
      final a = flatBoard[combination[0]];
      final b = flatBoard[combination[1]];
      final c = flatBoard[combination[2]];

      // If all three positions have the same non-empty value
      if (a.isNotEmpty && a == b && b == c) {
        return a; // Return 'X' or 'O'
      }
    }

    return ''; // No winner
  }

  // Check if board is full (draw)
  static bool isBoardFull(List<List<String>> board) {
    for (var row in board) {
      for (var cell in row) {
        if (cell.isEmpty) return false;
      }
    }
    return true;
  }

  // Get all empty cells
  static List<List<int>> getEmptyCells(List<List<String>> board) {
    List<List<int>> emptyCells = [];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          emptyCells.add([i, j]);
        }
      }
    }

    return emptyCells;
  }

  // Make app's move (with difficulty levels)
  static List<int>? makeAppMove(List<List<String>> board,
      {String difficulty = 'medium', Map<String, dynamic>? aiSettings}) {
    final emptyCells = getEmptyCells(board);

    // If no empty cells, return null
    if (emptyCells.isEmpty) return null;

    final random = Random();

    // Use AI settings if provided (for cyberpunk levels)
    if (aiSettings != null) {
      final randomChance = aiSettings['randomMoveChance'] ?? 0.0;
      final mistakeChance = aiSettings['mistakeChance'] ?? 0.0;
      final useMinimax = aiSettings['useMinimax'] ?? false;

      // Random move chance
      if (random.nextDouble() < randomChance) {
        return emptyCells[random.nextInt(emptyCells.length)];
      }

      // Use minimax for highest difficulty
      if (useMinimax) {
        return _minimaxMove(board, 'O', aiSettings['lookAhead'] ?? 4);
      }

      // Make a mistake occasionally
      if (random.nextDouble() < mistakeChance) {
        // Intentionally avoid the best move
        final bestMove = _findBestMove(board, 'O');
        if (bestMove != null) {
          emptyCells.removeWhere(
              (cell) => cell[0] == bestMove[0] && cell[1] == bestMove[1]);
        }
        if (emptyCells.isNotEmpty) {
          return emptyCells[random.nextInt(emptyCells.length)];
        }
      }
    }

    // Original difficulty system as fallback
    // Easy mode: completely random
    if (difficulty == 'easy') {
      return emptyCells[random.nextInt(emptyCells.length)];
    }

    // Medium mode: 70% smart moves, 30% random
    if (difficulty == 'medium') {
      if (random.nextDouble() < 0.3) {
        return emptyCells[random.nextInt(emptyCells.length)];
      }
    }

    // Hard mode (and fallback for medium): always play optimally
    return _findBestMove(board, 'O');
  }

  static List<int>? _findBestMove(List<List<String>> board, String player) {
    // Try to win first
    final winningMove = findWinningMove(board, player);
    if (winningMove != null) return winningMove;

    // Try to block opponent from winning
    final opponent = player == 'O' ? 'X' : 'O';
    final blockingMove = findWinningMove(board, opponent);
    if (blockingMove != null) return blockingMove;

    // Try to take center
    if (board[1][1].isEmpty) return [1, 1];

    // Try to take corners
    final corners = [
      [0, 0],
      [0, 2],
      [2, 0],
      [2, 2]
    ];
    final emptyCorners =
        corners.where((corner) => board[corner[0]][corner[1]].isEmpty).toList();

    if (emptyCorners.isNotEmpty) {
      final random = Random();
      return emptyCorners[random.nextInt(emptyCorners.length)];
    }

    // Take any empty cell
    final emptyCells = getEmptyCells(board);
    final random = Random();
    return emptyCells[random.nextInt(emptyCells.length)];
  }

  // Minimax algorithm for perfect play
  static List<int>? _minimaxMove(
      List<List<String>> board, String player, int maxDepth) {
    int bestScore = -1000;
    List<int>? bestMove;

    final emptyCells = getEmptyCells(board);

    for (final cell in emptyCells) {
      // Make the move
      board[cell[0]][cell[1]] = player;

      // Calculate score for this move
      final score = _minimax(board, 0, false, player, maxDepth, -1000, 1000);

      // Undo the move
      board[cell[0]][cell[1]] = '';

      // Update best move if this is better
      if (score > bestScore) {
        bestScore = score;
        bestMove = cell;
      }
    }

    return bestMove;
  }

  static int _minimax(List<List<String>> board, int depth, bool isMaximizing,
      String aiPlayer, int maxDepth, int alpha, int beta) {
    // Check terminal states
    final winner = checkWinner(board);
    if (winner == aiPlayer) return 10 - depth;
    if (winner.isNotEmpty) return depth - 10;
    if (isBoardFull(board) || depth >= maxDepth) return 0;

    final currentPlayer =
        isMaximizing ? aiPlayer : (aiPlayer == 'O' ? 'X' : 'O');

    if (isMaximizing) {
      int maxEval = -1000;
      final emptyCells = getEmptyCells(board);

      for (final cell in emptyCells) {
        board[cell[0]][cell[1]] = currentPlayer;
        final eval =
            _minimax(board, depth + 1, false, aiPlayer, maxDepth, alpha, beta);
        board[cell[0]][cell[1]] = '';

        maxEval = math.max(maxEval, eval);
        alpha = math.max(alpha, eval);

        if (beta <= alpha) break; // Alpha-beta pruning
      }

      return maxEval;
    } else {
      int minEval = 1000;
      final emptyCells = getEmptyCells(board);

      for (final cell in emptyCells) {
        board[cell[0]][cell[1]] = currentPlayer;
        final eval =
            _minimax(board, depth + 1, true, aiPlayer, maxDepth, alpha, beta);
        board[cell[0]][cell[1]] = '';

        minEval = math.min(minEval, eval);
        beta = math.min(beta, eval);

        if (beta <= alpha) break; // Alpha-beta pruning
      }

      return minEval;
    }
  }

  // Find a winning move for the given player
  static List<int>? findWinningMove(List<List<String>> board, String player) {
    final emptyCells = getEmptyCells(board);

    // Try each empty cell
    for (final cell in emptyCells) {
      // Make a copy of the board
      final testBoard = board.map((row) => List<String>.from(row)).toList();

      // Try the move
      testBoard[cell[0]][cell[1]] = player;

      // Check if this move wins
      if (checkWinner(testBoard) == player) {
        return cell;
      }
    }

    return null;
  }

  // Get a hint for the player
  static List<int>? getHint(List<List<String>> board) {
    // First check if player can win
    final winningMove = findWinningMove(board, 'X');
    if (winningMove != null) return winningMove;

    // Then check if need to block opponent
    final blockingMove = findWinningMove(board, 'O');
    if (blockingMove != null) return blockingMove;

    // Otherwise suggest center or corner
    if (board[1][1].isEmpty) return [1, 1];

    final corners = [
      [0, 0],
      [0, 2],
      [2, 0],
      [2, 2]
    ];
    for (final corner in corners) {
      if (board[corner[0]][corner[1]].isEmpty) return corner;
    }

    // Return any empty cell
    return getEmptyCells(board).firstOrNull;
  }
}
