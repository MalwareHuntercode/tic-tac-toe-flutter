// lib/screens/cyberpunk_game_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/cyberpunk_game_board.dart';
import '../services/game_logic.dart';
import '../services/game_analyzer.dart';
import '../models/game.dart';
import '../models/difficulty_level.dart';
import '../services/storage_service.dart';
import '../theme/cyberpunk_theme.dart';
import 'game_analysis_screen.dart';

class CyberpunkGameScreen extends StatefulWidget {
  final int currentScore;
  final String playerName;
  final int winStreak;
  final bool useTimer;
  final int currentLevel;

  const CyberpunkGameScreen({
    Key? key,
    required this.currentScore,
    required this.playerName,
    this.winStreak = 0,
    this.useTimer = true,
    this.currentLevel = 1,
  }) : super(key: key);

  @override
  State<CyberpunkGameScreen> createState() => _CyberpunkGameScreenState();
}

class _CyberpunkGameScreenState extends State<CyberpunkGameScreen>
    with TickerProviderStateMixin {
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

  // Timer variables
  Timer? _timer;
  int _timeRemaining = 30;
  late int _timeLimit;

  // Difficulty level
  late DifficultyLevel _difficulty;

  // Move history for analysis
  List<GameMove> _moveHistory = [];

  // Animation controllers
  late AnimationController _levelUpController;
  late Animation<double> _levelUpAnimation;

  @override
  void initState() {
    super.initState();
    _difficulty = DifficultyLevel.getCurrentLevel(widget.currentScore);
    _timeLimit = _difficulty.moveTimeLimit;
    _resetGame();
    _startTimer();

    // Level up animation
    _levelUpController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _levelUpAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _levelUpController,
      curve: Curves.elasticOut,
    ));

    // Check for level up
    _checkLevelUp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _levelUpController.dispose();
    super.dispose();
  }

  void _checkLevelUp() {
    final newLevel = DifficultyLevel.getCurrentLevel(widget.currentScore);
    if (newLevel.level > widget.currentLevel) {
      _levelUpController.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        _showLevelUpDialog(newLevel);
      });
    }
  }

  void _showLevelUpDialog(DifficultyLevel newLevel) {
    final theme = CyberpunkTheme.levelThemes[newLevel.level - 1];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Theme(
        data: CyberpunkTheme.getTheme(newLevel.level),
        child: AlertDialog(
          backgroundColor: theme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.primary, width: 2),
          ),
          title: Column(
            children: [
              Icon(
                Icons.arrow_upward,
                color: theme.primary,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'LEVEL UP!',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 24,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to Level ${newLevel.level}',
                style: TextStyle(color: theme.primary, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                newLevel.name,
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                newLevel.description,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.primary.withOpacity(0.8)),
              ),
              const SizedBox(height: 16),
              Text(
                'New time limit: ${newLevel.moveTimeLimit}s',
                style: TextStyle(color: theme.accent),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CONTINUE',
                style: TextStyle(color: theme.primary),
              ),
            ),
          ],
        ),
      ),
    );
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
      _timeRemaining = _timeLimit;
      _moveHistory = [];
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!widget.useTimer || !isPlayerTurn || gameStatus != 'playing') return;

    setState(() {
      _timeRemaining = _timeLimit;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _timeRemaining--;
      });

      if (_timeRemaining <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _handleTimeout() {
    if (!isPlayerTurn || gameStatus != 'playing') return;

    // Make a random move for the player
    final emptyCells = GameLogic.getEmptyCells(board);
    if (emptyCells.isNotEmpty) {
      final randomIndex = DateTime.now().millisecond % emptyCells.length;
      final randomCell = emptyCells[randomIndex];

      // Show timeout message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('TIME\'S UP! Random move made.'),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      // Make the move
      _handleCellTap(randomCell[0], randomCell[1]);
    }
  }

  void _handleCellTap(int row, int col) {
    // Only process if game is still playing
    if (gameStatus != 'playing' || board[row][col].isNotEmpty) return;

    // Stop the timer
    _stopTimer();

    // Record the move
    _moveHistory.add(GameMove(row: row, col: col, player: 'X'));

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

    // Get app's move based on difficulty
    final move = GameLogic.makeAppMove(
      board,
      aiSettings: _difficulty.aiSettings,
    );

    if (move != null) {
      // Record the move
      _moveHistory.add(GameMove(row: move[0], col: move[1], player: 'O'));

      setState(() {
        board[move[0]][move[1]] = 'O';
        isPlayerTurn = true;
      });

      // Check if app won
      if (!_checkGameEnd()) {
        // Restart timer for player's next turn
        _startTimer();
      }
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
      _stopTimer();
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
      _stopTimer();
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

    // Save game to storage
    StorageService.saveGame(game);
  }

  void _showHint() {
    if (!_difficulty.showHints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hints disabled at ${_difficulty.name} level!'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

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
    }
  }

  void _showGameEndDialog() {
    String title;
    String message;
    IconData icon;
    Color color;

    final theme = CyberpunkTheme.levelThemes[(_difficulty.level - 1)
        .clamp(0, CyberpunkTheme.levelThemes.length - 1)];

    switch (gameStatus) {
      case 'win':
        title = 'VICTORY!';
        message = 'You defeated the AI! +10 points';
        icon = Icons.emoji_events;
        color = Colors.green;
        break;
      case 'loss':
        title = 'DEFEATED';
        message = 'The AI won! -10 points';
        icon = Icons.sentiment_dissatisfied;
        color = Colors.red;
        break;
      case 'draw':
        title = 'DRAW';
        message = 'No winner this time!';
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
          return Theme(
            data: CyberpunkTheme.getTheme(_difficulty.level),
            child: AlertDialog(
              backgroundColor: theme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: color, width: 2),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(color: color, letterSpacing: 2),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: TextStyle(color: theme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'New Score: ${widget.currentScore + scoreChange}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.accent,
                    ),
                  ),
                  if (gameStatus == 'win' && widget.winStreak > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '🔥 Win Streak: ${widget.winStreak + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Show game analysis
                    _showGameAnalysis();
                  },
                  child: Text(
                    'ANALYZE GAME',
                    style: TextStyle(color: theme.primary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Return score change and game result to home screen
                    Navigator.of(context).pop({
                      'scoreChange': scoreChange,
                      'gameResult': gameStatus,
                    });
                  },
                  child: Text(
                    'BACK TO HOME',
                    style: TextStyle(color: theme.accent),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void _showGameAnalysis() {
    final analysis = GameAnalyzer.analyzeGame(_moveHistory, gameStatus);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameAnalysisScreen(
          analysis: analysis,
          moveHistory: _moveHistory,
          level: _difficulty.level,
        ),
      ),
    ).then((_) {
      _resetGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CyberpunkTheme.levelThemes[(_difficulty.level - 1)
        .clamp(0, CyberpunkTheme.levelThemes.length - 1)];

    return Theme(
      data: CyberpunkTheme.getTheme(_difficulty.level),
      child: WillPopScope(
        onWillPop: () async {
          // If game ended, return score change and result
          if (gameStatus != 'playing') {
            Navigator.of(context).pop({
              'scoreChange': scoreChange,
              'gameResult': gameStatus,
            });
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            title: Text(
              'LEVEL ${_difficulty.level} - ${_difficulty.name.toUpperCase()}',
              style: const TextStyle(letterSpacing: 2),
            ),
            centerTitle: true,
            actions: [
              if (_difficulty.showHints)
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
            child: Column(
              children: [
                // Game status card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.surface.withOpacity(0.8),
                        theme.surface.withOpacity(0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.primary, width: 2),
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
                                ? (isPlayerTurn ? theme.primary : theme.accent)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            gameStatus == 'playing'
                                ? (isPlayerTurn
                                    ? 'YOUR TURN'
                                    : 'AI THINKING...')
                                : 'GAME OVER',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: theme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (!isPlayerTurn && gameStatus == 'playing') ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(theme.accent),
                          backgroundColor: theme.surface,
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Score and level info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoItem(
                              'SCORE', '${widget.currentScore}', theme),
                          if (widget.winStreak > 0)
                            _buildInfoItem(
                                'STREAK', '${widget.winStreak}🔥', theme),
                          _buildInfoItem(
                              'AI STRENGTH',
                              '${(_difficulty.aiStrength * 100).toInt()}%',
                              theme),
                        ],
                      ),
                    ],
                  ),
                ),

                // Timer display
                if (widget.useTimer && isPlayerTurn && gameStatus == 'playing')
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildTimer(theme),
                  ),

                const SizedBox(height: 20),

                // Game board
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CyberpunkGameBoard(
                        board: board,
                        onCellTap: _handleCellTap,
                        isPlayerTurn: isPlayerTurn,
                        hintCell: hintCell,
                        level: _difficulty.level,
                      ),
                    ),
                  ),
                ),

                // Player stats
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.primary.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPlayerCard(
                          widget.playerName, 'X', theme.primary, theme),
                      Container(
                        width: 2,
                        height: 40,
                        color: theme.primary.withOpacity(0.3),
                      ),
                      _buildPlayerCard(
                          'AI v${_difficulty.level}', 'O', theme.accent, theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, LevelTheme theme) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.primary.withOpacity(0.6),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimer(LevelTheme theme) {
    final progress = _timeRemaining / _timeLimit;
    final isUrgent = _timeRemaining <= 5;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red.withOpacity(0.1)
            : theme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUrgent ? Colors.red : theme.primary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUrgent ? Icons.timer_off : Icons.timer,
                color: isUrgent ? Colors.red : theme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '$_timeRemaining',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? Colors.red : theme.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SEC',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      (isUrgent ? Colors.red : theme.primary).withOpacity(0.7),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: theme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              isUrgent ? Colors.red : theme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(
      String name, String symbol, Color color, LevelTheme theme) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            color: theme.primary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
