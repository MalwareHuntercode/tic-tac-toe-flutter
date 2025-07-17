// lib/services/game_analyzer.dart

import '../services/game_logic.dart';

class GameAnalyzer {
  // Analyze a completed game and find mistakes
  static GameAnalysis analyzeGame(List<GameMove> moveHistory, String result) {
    List<MoveAnalysis> moveAnalyses = [];
    List<List<String>> board = [
      ['', '', ''],
      ['', '', ''],
      ['', '', ''],
    ];

    for (int i = 0; i < moveHistory.length; i++) {
      final move = moveHistory[i];
      final isPlayerMove = move.player == 'X';

      if (isPlayerMove) {
        // Analyze player's move
        final analysis = _analyzePlayerMove(board, move, i);
        moveAnalyses.add(analysis);
      }

      // Apply the move to the board
      board[move.row][move.col] = move.player;
    }

    // Calculate overall performance
    final totalMoves = moveAnalyses.length;
    final perfectMoves =
        moveAnalyses.where((a) => a.quality == MoveQuality.perfect).length;
    final goodMoves =
        moveAnalyses.where((a) => a.quality == MoveQuality.good).length;
    final mistakes =
        moveAnalyses.where((a) => a.quality == MoveQuality.mistake).length;
    final blunders =
        moveAnalyses.where((a) => a.quality == MoveQuality.blunder).length;

    final score = _calculatePerformanceScore(
        perfectMoves, goodMoves, mistakes, blunders, totalMoves);

    return GameAnalysis(
      moveAnalyses: moveAnalyses,
      result: result,
      performanceScore: score,
      perfectMoves: perfectMoves,
      mistakes: mistakes,
      blunders: blunders,
      summary: _generateSummary(score, result, moveAnalyses),
    );
  }

  static MoveAnalysis _analyzePlayerMove(
      List<List<String>> board, GameMove move, int moveNumber) {
    // Check if this was a winning move
    final boardAfterMove = _copyBoard(board);
    boardAfterMove[move.row][move.col] = 'X';

    if (GameLogic.checkWinner(boardAfterMove) == 'X') {
      return MoveAnalysis(
        move: move,
        quality: MoveQuality.perfect,
        explanation: 'Winning move! Well played.',
        bestMove: move,
      );
    }

    // Check if player missed a winning move
    final winningMove = GameLogic.findWinningMove(board, 'X');
    if (winningMove != null &&
        (winningMove[0] != move.row || winningMove[1] != move.col)) {
      return MoveAnalysis(
        move: move,
        quality: MoveQuality.blunder,
        explanation: 'You missed a winning move!',
        bestMove:
            GameMove(row: winningMove[0], col: winningMove[1], player: 'X'),
      );
    }

    // Check if player blocked opponent's winning move
    final opponentWin = GameLogic.findWinningMove(board, 'O');
    if (opponentWin != null) {
      if (opponentWin[0] == move.row && opponentWin[1] == move.col) {
        return MoveAnalysis(
          move: move,
          quality: MoveQuality.perfect,
          explanation: 'Good block! Prevented opponent from winning.',
          bestMove: move,
        );
      } else {
        return MoveAnalysis(
          move: move,
          quality: MoveQuality.blunder,
          explanation: 'You missed blocking the opponent\'s winning move!',
          bestMove:
              GameMove(row: opponentWin[0], col: opponentWin[1], player: 'X'),
        );
      }
    }

    // Evaluate strategic moves
    if (moveNumber == 0) {
      // First move
      if (move.row == 1 && move.col == 1) {
        return MoveAnalysis(
          move: move,
          quality: MoveQuality.perfect,
          explanation: 'Perfect opening! Center is the strongest first move.',
          bestMove: move,
        );
      } else if (_isCorner(move.row, move.col)) {
        return MoveAnalysis(
          move: move,
          quality: MoveQuality.good,
          explanation: 'Good opening. Corners are strong starting positions.',
          bestMove: move,
        );
      } else {
        return MoveAnalysis(
          move: move,
          quality: MoveQuality.mistake,
          explanation:
              'Weak opening. Center or corners are better first moves.',
          bestMove: GameMove(row: 1, col: 1, player: 'X'),
        );
      }
    }

    // General strategic evaluation
    final boardControl = _evaluateBoardControl(boardAfterMove, 'X');
    if (boardControl >= 0.7) {
      return MoveAnalysis(
        move: move,
        quality: MoveQuality.good,
        explanation: 'Good strategic move. Maintaining board control.',
        bestMove: move,
      );
    }

    return MoveAnalysis(
      move: move,
      quality: MoveQuality.good,
      explanation: 'Decent move.',
      bestMove: move,
    );
  }

  static bool _isCorner(int row, int col) {
    return (row == 0 || row == 2) && (col == 0 || col == 2);
  }

  static List<List<String>> _copyBoard(List<List<String>> board) {
    return board.map((row) => List<String>.from(row)).toList();
  }

  static double _evaluateBoardControl(List<List<String>> board, String player) {
    int controlledLines = 0;
    int totalLines = 8; // 3 rows + 3 cols + 2 diagonals

    // Check rows
    for (int i = 0; i < 3; i++) {
      if (_lineHasPotential(board[i], player)) controlledLines++;
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      final col = [board[0][i], board[1][i], board[2][i]];
      if (_lineHasPotential(col, player)) controlledLines++;
    }

    // Check diagonals
    final diag1 = [board[0][0], board[1][1], board[2][2]];
    final diag2 = [board[0][2], board[1][1], board[2][0]];
    if (_lineHasPotential(diag1, player)) controlledLines++;
    if (_lineHasPotential(diag2, player)) controlledLines++;

    return controlledLines / totalLines;
  }

  static bool _lineHasPotential(List<String> line, String player) {
    final opponent = player == 'X' ? 'O' : 'X';
    return !line.contains(opponent) && line.contains(player);
  }

  static int _calculatePerformanceScore(
      int perfect, int good, int mistakes, int blunders, int total) {
    if (total == 0) return 0;

    final score =
        ((perfect * 100) + (good * 70) - (mistakes * 30) - (blunders * 50)) ~/
            total;
    return score.clamp(0, 100);
  }

  static String _generateSummary(
      int score, String result, List<MoveAnalysis> moves) {
    String summary = '';

    if (score >= 90) {
      summary = 'Outstanding performance! You played nearly perfectly.';
    } else if (score >= 75) {
      summary = 'Great game! You made mostly optimal moves.';
    } else if (score >= 60) {
      summary = 'Good effort, but there\'s room for improvement.';
    } else if (score >= 40) {
      summary = 'You made several mistakes. Study the analysis to improve.';
    } else {
      summary =
          'This game had many missed opportunities. Practice makes perfect!';
    }

    if (result == 'loss' &&
        moves.any((m) => m.quality == MoveQuality.blunder)) {
      summary += ' Critical mistakes led to your defeat.';
    } else if (result == 'win' && score < 60) {
      summary += ' You won despite the mistakes - your opponent played worse!';
    }

    return summary;
  }
}

// Data classes for analysis
class GameMove {
  final int row;
  final int col;
  final String player;

  const GameMove({
    required this.row,
    required this.col,
    required this.player,
  });
}

class MoveAnalysis {
  final GameMove move;
  final MoveQuality quality;
  final String explanation;
  final GameMove bestMove;

  const MoveAnalysis({
    required this.move,
    required this.quality,
    required this.explanation,
    required this.bestMove,
  });
}

enum MoveQuality {
  perfect,
  good,
  mistake,
  blunder,
}

class GameAnalysis {
  final List<MoveAnalysis> moveAnalyses;
  final String result;
  final int performanceScore;
  final int perfectMoves;
  final int mistakes;
  final int blunders;
  final String summary;

  const GameAnalysis({
    required this.moveAnalyses,
    required this.result,
    required this.performanceScore,
    required this.perfectMoves,
    required this.mistakes,
    required this.blunders,
    required this.summary,
  });
}
