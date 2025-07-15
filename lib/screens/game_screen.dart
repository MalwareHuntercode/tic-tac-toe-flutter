// lib/screens/game_screen.dart

import 'package:flutter/material.dart';
import '../widgets/game_board.dart';
import '../services/game_logic.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

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
      });
      _showGameEndDialog();
      return true;
    }

    // Check for draw
    if (GameLogic.isBoardFull(board)) {
      setState(() {
        gameStatus = 'draw';
      });
      _showGameEndDialog();
      return true;
    }

    return false;
  }

  void _showGameEndDialog() {
    String title;
    String message;
    IconData icon;
    Color color;

    switch (gameStatus) {
      case 'win':
        title = 'Congratulations! 🎉';
        message = 'You won the game!';
        icon = Icons.emoji_events;
        color = Colors.green;
        break;
      case 'loss':
        title = 'Game Over 😔';
        message = 'Better luck next time!';
        icon = Icons.sentiment_dissatisfied;
        color = Colors.red;
        break;
      case 'draw':
        title = 'It\'s a Draw! 🤝';
        message = 'Good game!';
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
                Text(title),
              ],
            ),
            content: Text(message),
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
                  Navigator.of(context).pop();
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
    return Scaffold(
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
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Quick stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('You', 'X', Colors.blue),
                  _buildStatCard('App', 'O', Colors.red),
                ],
              ),
            ],
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
