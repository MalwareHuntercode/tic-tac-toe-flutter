// lib/screens/cyberpunk_history_screen.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/game.dart';
import '../models/difficulty_level.dart';
import '../services/storage_service.dart';
import '../theme/cyberpunk_theme.dart';

class CyberpunkHistoryScreen extends StatefulWidget {
  const CyberpunkHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CyberpunkHistoryScreen> createState() => _CyberpunkHistoryScreenState();
}

class _CyberpunkHistoryScreenState extends State<CyberpunkHistoryScreen>
    with TickerProviderStateMixin {
  List<Game> _gameHistory = [];
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  int _currentLevel = 1;

  // Animation controllers
  late AnimationController _glitchController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadGameHistory();

    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
    _startRandomGlitch();
  }

  void _startRandomGlitch() {
    Future.delayed(Duration(seconds: 2 + math.Random().nextInt(4)), () {
      if (mounted) {
        _glitchController.forward().then((_) {
          _glitchController.reverse();
        });
        _startRandomGlitch();
      }
    });
  }

  @override
  void dispose() {
    _glitchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadGameHistory() async {
    final history = await StorageService.loadGameHistory();

    // Get current player name for statistics
    final currentPlayer = await StorageService.loadPlayer();
    if (currentPlayer != null) {
      final stats =
          await StorageService.getPlayerStatistics(currentPlayer.name);
      setState(() {
        _gameHistory = history
            .where((game) => game.playerName == currentPlayer.name)
            .toList();
        _statistics = stats;
        _currentLevel =
            DifficultyLevel.getCurrentLevel(currentPlayer.score).level;
        _isLoading = false;
      });
    } else {
      setState(() {
        _gameHistory = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final theme = CyberpunkTheme.levelThemes[
        (_currentLevel - 1).clamp(0, CyberpunkTheme.levelThemes.length - 1)];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: CyberpunkTheme.getTheme(_currentLevel),
        child: AlertDialog(
          backgroundColor: theme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.primary, width: 2),
          ),
          title: Text(
            'CLEAR HISTORY?',
            style: TextStyle(
              color: theme.primary,
              letterSpacing: 2,
            ),
          ),
          content: Text(
            'This will delete all your game history. This action cannot be undone.',
            style: TextStyle(color: theme.primary.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('CANCEL', style: TextStyle(color: theme.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('DELETE'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await StorageService.clearGameHistory();
      _loadGameHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CyberpunkTheme.levelThemes[
        (_currentLevel - 1).clamp(0, CyberpunkTheme.levelThemes.length - 1)];

    return Theme(
      data: CyberpunkTheme.getTheme(_currentLevel),
      child: Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(
          title: AnimatedBuilder(
            animation: _glitchController,
            builder: (context, child) {
              final offset = _glitchController.value * 2;
              return Transform.translate(
                offset:
                    Offset(math.Random().nextDouble() * offset - offset / 2, 0),
                child: const Text(
                  'GAME HISTORY',
                  style: TextStyle(letterSpacing: 3),
                ),
              );
            },
          ),
          centerTitle: true,
          actions: [
            if (_gameHistory.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _clearHistory,
                tooltip: 'Clear History',
              ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: _gameHistory.isEmpty
                    ? _buildEmptyState(theme)
                    : Column(
                        children: [
                          // Statistics Panel
                          _buildStatisticsPanel(theme),

                          // History List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _gameHistory.length,
                              itemBuilder: (context, index) {
                                final game = _gameHistory[index];
                                return _buildHistoryCard(game, index, theme);
                              },
                            ),
                          ),
                        ],
                      ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(LevelTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: theme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'NO RECORDS FOUND',
            style: TextStyle(
              fontSize: 24,
              color: theme.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start playing to see your history',
            style: TextStyle(
              fontSize: 14,
              color: theme.primary.withOpacity(0.5),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsPanel(LevelTheme theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withOpacity(0.1),
            theme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.neonGlow.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'BATTLE STATISTICS',
            style: TextStyle(
              color: theme.primary,
              fontSize: 18,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Stats Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'TOTAL',
                _statistics['totalGames']?.toString() ?? '0',
                Icons.gamepad,
                theme.primary,
                theme,
              ),
              _buildStatItem(
                'WINS',
                _statistics['wins']?.toString() ?? '0',
                Icons.emoji_events,
                Colors.green,
                theme,
              ),
              _buildStatItem(
                'LOSSES',
                _statistics['losses']?.toString() ?? '0',
                Icons.close,
                Colors.red,
                theme,
              ),
              _buildStatItem(
                'DRAWS',
                _statistics['draws']?.toString() ?? '0',
                Icons.handshake,
                Colors.orange,
                theme,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Win Rate Bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WIN RATE',
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${_statistics['winRate'] ?? '0.0'}%',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: double.parse((_statistics['winRate'] ?? '0')
                        .toString()
                        .replaceAll('%', '')) /
                    100,
                minHeight: 8,
                backgroundColor: theme.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Best Streak
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'BEST STREAK: ${_statistics['longestStreak'] ?? 0}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.local_fire_department, color: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color,
      LevelTheme theme) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: theme.primary.withOpacity(0.7),
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Game game, int index, LevelTheme theme) {
    final color = game.getResultColor();
    final icon = game.getResultIcon();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.surface.withOpacity(0.8),
            theme.surface.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        childrenPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.background,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        title: Row(
          children: [
            Text(
              'GAME #${_gameHistory.length - index}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.primary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(
                game.result.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              game.getFormattedDate(),
              style: TextStyle(
                color: theme.primary.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            if (game.scoreChange != 0)
              Text(
                'SCORE: ${game.scoreChange > 0 ? '+' : ''}${game.scoreChange}',
                style: TextStyle(
                  color: game.scoreChange > 0 ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: theme.primary,
        ),
        children: [
          // Game Board Display
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.primary.withOpacity(0.3)),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 9,
                itemBuilder: (context, cellIndex) {
                  final row = cellIndex ~/ 3;
                  final col = cellIndex % 3;
                  final value = game.finalBoard[row][col];

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: value.isEmpty
                            ? theme.primary.withOpacity(0.3)
                            : value == 'X'
                                ? theme.primary
                                : theme.accent,
                        width: 2,
                      ),
                      boxShadow: value.isNotEmpty
                          ? [
                              BoxShadow(
                                color: (value == 'X'
                                        ? theme.primary
                                        : theme.accent)
                                    .withOpacity(0.3),
                                blurRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: value == 'X' ? theme.primary : theme.accent,
                          shadows: [
                            Shadow(
                              color:
                                  (value == 'X' ? theme.primary : theme.accent)
                                      .withOpacity(0.8),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
