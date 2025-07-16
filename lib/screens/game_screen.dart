// lib/screens/game_screen.dart

import 'package:flutter/material.dart';
import '../widgets/game_board.dart';
import '../services/game_logic.dart';
import '../models/game.dart';
import '../services/storage_service.dart';

class GameScreen extends StatefulWidget {
  final int currentScore;
  final String playerName;

  const GameScreen({
    Key? key,
    required this.currentScore,
    required this.playerName,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game board - 3x3 grid
  List<List<String>> board = [
    ['', '', ''],
    ['', '', ''],
    ['', '', ''],
  ];

  // Track whose turn it is
  bool isPlayerTurn = true;

  // Game state
  String gameStatus = 'playing'; // 'playing', 'win', 'loss', 'draw'

  // Score change for this game
  int scoreChange = 0;

  // Hint cell
  List<int>? hintCell;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      board = [
        ['', '', ''],
        ['', '', ''],
        ['', '', ''],
      ];
      isPlayerTurn = true;
      gameStatus = 'playing';
      scoreChange = 0;
      hintCell = null;
    });
  }

  void _handleCellTap(int row, int col) {
    // Only process if game is still playing
    if (gameStatus != 'playing') return;

    // Make player move
    setState(() {
      board[row][col] = 'X';
      isPlayerTurn = false;
    });

    // Check if player won
    if (_checkGameEnd()) return;

    // Make app move after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _makeAppMove();
    });
  }

  void _makeAppMove() {
    if (gameStatus != 'playing') return;

    // Get app's move
    final move = GameLogic.makeAppMove(board);
    if (move != null) {
      setState(() {
        board[move[0]][move[1]] = 'O';
        isPlayerTurn = true;
      });

      // Check if app won
      _checkGameEnd();
    }
  }

  bool _checkGameEnd() {
    // Check for winner
    final winner = GameLogic.checkWinner(board);
    if (winner.isNotEmpty) {
      setState(() {
        gameStatus = winner == 'X' ? 'win' : 'loss';
        // Update score change
        scoreChange = winner == 'X' ? 10 : -10;
      });
      _saveGameResult();
      _showGameEndDialog();
      return true;
    }

    // Check for draw
    if (GameLogic.isBoardFull(board)) {
      setState(() {
        gameStatus = 'draw';
        scoreChange = 0; // No score change for draw
      });
      _saveGameResult();
      _showGameEndDialog();
      return true;
    }

    return false;
  }

  void _saveGameResult() {
    final game = Game(
      timestamp: DateTime.now(),
      result: gameStatus,
      finalBoard: board.map((row) => List<String>.from(row)).toList(),
      playerName: widget.playerName,
      scoreChange: scoreChange,
    );

    // Save game to storage (we'll implement actual storage in Phase 5)
    StorageService.saveGame(game);
  }

  void _showHint() {
    final hint = GameLogic.getHint(board);
    if (hint != null) {
      setState(() {
        hintCell = hint;
      });

      // Remove hint after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            hintCell = null;
          });
        }
      });

      // Show hint message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Try cell at row ${hint[0] + 1}, column ${hint[1] + 1}',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showGameEndDialog() {
    String title;
    String message;
    IconData icon;
    Color color;

    switch (gameStatus) {
      case 'win':
        title = 'Congratulations! 🎉';
        message = 'You won! +10 points';
        icon = Icons.emoji_events;
        color = Colors.green;
        break;
      case 'loss':
        title = 'Game Over 😔';
        message = 'You lost! -10 points';
        icon = Icons.sentiment_dissatisfied;
        color = Colors.red;
        break;
      case 'draw':
        title = 'It\'s a Draw! 🤝';
        message = 'No points change';
        icon = Icons.handshake;
        color = Colors.orange;
        break;
      default:
        return;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 8),
                Expanded(child: Text(title)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 16),
                Text(
                  'New Score: ${widget.currentScore + scoreChange}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetGame();
                },
                child: const Text('Play Again'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Return score change to home screen
                  Navigator.of(context).pop(scoreChange);
                },
                child: const Text('Back to Home'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If game ended, return score change
        if (gameStatus != 'playing') {
          Navigator.of(context).pop(scoreChange);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Play Game',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: isPlayerTurn && gameStatus == 'playing'
                  ? _showHint
                  : null,
              tooltip: 'Get Hint',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetGame,
              tooltip: 'Reset Game',
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Game status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Turn indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            gameStatus == 'playing'
                                ? (isPlayerTurn ? Icons.person : Icons.computer)
                                : Icons.flag,
                            color: gameStatus == 'playing'
                                ? (isPlayerTurn ? Colors.blue : Colors.red)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            gameStatus == 'playing'
                                ? (isPlayerTurn
                                      ? 'Your Turn (X)'
                                      : 'App\'s Turn (O)')
                                : 'Game Over',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (!isPlayerTurn && gameStatus == 'playing') ...[
                        const SizedBox(height: 8),
                        const LinearProgressIndicator(),
                      ],
                      const SizedBox(height: 8),
                      // Current score display
                      Text(
                        'Current Score: ${widget.currentScore}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Game board
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: GameBoard(
                        board: board,
                        onCellTap: _handleCellTap,
                        isPlayerTurn: isPlayerTurn,
                        hintCell: hintCell,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Quick stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(widget.playerName, 'X', Colors.blue),
                    _buildStatCard('App', 'O', Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String symbol, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            symbol,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
