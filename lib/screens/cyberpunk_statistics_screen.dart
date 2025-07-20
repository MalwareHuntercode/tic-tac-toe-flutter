// lib/screens/cyberpunk_statistics_screen.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/player.dart';
import '../models/difficulty_level.dart';
import '../services/storage_service.dart';
import '../theme/cyberpunk_theme.dart';

class CyberpunkStatisticsScreen extends StatefulWidget {
  const CyberpunkStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<CyberpunkStatisticsScreen> createState() =>
      _CyberpunkStatisticsScreenState();
}

class _CyberpunkStatisticsScreenState extends State<CyberpunkStatisticsScreen>
    with TickerProviderStateMixin {
  List<Player> _allPlayers = [];
  Player? _currentPlayer;
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  int _currentLevel = 1;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final currentPlayer = await StorageService.loadPlayer();
    final allPlayers = await StorageService.getAllPlayers();

    Map<String, dynamic> stats = {};
    if (currentPlayer != null) {
      stats = await StorageService.getPlayerStatistics(currentPlayer.name);
      setState(() {
        _currentLevel =
            DifficultyLevel.getCurrentLevel(currentPlayer.score).level;
      });
    }

    setState(() {
      _currentPlayer = currentPlayer;
      _allPlayers = allPlayers;
      _statistics = stats;
      _isLoading = false;
    });
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
          title: const Text(
            'CYBER LEADERBOARD',
            style: TextStyle(letterSpacing: 3),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Current Player Stats
                    if (_currentPlayer != null)
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildPlayerStatsCard(theme),
                      ),

                    const SizedBox(height: 24),

                    // Leaderboard Title
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 2,
                            width: 50,
                            color: theme.primary,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'TOP PLAYERS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            height: 2,
                            width: 50,
                            color: theme.primary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Leaderboard
                    _buildLeaderboard(theme),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPlayerStatsCard(LevelTheme theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primary.withOpacity(0.2),
                theme.secondary.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: theme.neonGlow.withOpacity(0.5 * _pulseAnimation.value),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Player Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.primary, width: 2),
                      gradient: RadialGradient(
                        colors: [
                          theme.primary.withOpacity(0.3),
                          theme.primary.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: theme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AGENT',
                        style: TextStyle(
                          color: theme.primary.withOpacity(0.7),
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        _currentPlayer!.name.toUpperCase(),
                        style: TextStyle(
                          color: theme.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: theme.neonGlow,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'SCORE',
                    _currentPlayer!.score.toString(),
                    Icons.stars,
                    Colors.yellow,
                    theme,
                  ),
                  _buildStatCard(
                    'BATTLES',
                    _statistics['totalGames']?.toString() ?? '0',
                    Icons.gamepad,
                    theme.primary,
                    theme,
                  ),
                  _buildStatCard(
                    'WIN RATE',
                    '${_statistics['winRate'] ?? '0.0'}%',
                    Icons.trending_up,
                    Colors.green,
                    theme,
                  ),
                  _buildStatCard(
                    'MAX STREAK',
                    '${_statistics['longestStreak'] ?? 0}',
                    Icons.local_fire_department,
                    Colors.orange,
                    theme,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Battle Results
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBattleResult(
                      'WINS',
                      _statistics['wins'] ?? 0,
                      Colors.green,
                      theme,
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: theme.primary.withOpacity(0.3),
                    ),
                    _buildBattleResult(
                      'LOSSES',
                      _statistics['losses'] ?? 0,
                      Colors.red,
                      theme,
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: theme.primary.withOpacity(0.3),
                    ),
                    _buildBattleResult(
                      'DRAWS',
                      _statistics['draws'] ?? 0,
                      Colors.orange,
                      theme,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Level Progress
              _buildLevelProgress(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color,
      LevelTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: theme.primary.withOpacity(0.5),
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleResult(
      String label, int value, Color color, LevelTheme theme) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 15,
              ),
            ],
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
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

  Widget _buildLevelProgress(LevelTheme theme) {
    final currentLevel = DifficultyLevel.getCurrentLevel(_currentPlayer!.score);
    final nextLevel = DifficultyLevel.getNextLevel(_currentPlayer!.score);

    if (nextLevel == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.yellow.withOpacity(0.2),
              Colors.orange.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.yellow),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.yellow, size: 28),
            const SizedBox(width: 12),
            Text(
              'MAXIMUM LEVEL ACHIEVED!',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.star, color: Colors.yellow, size: 28),
          ],
        ),
      );
    }

    final progress = (_currentPlayer!.score - currentLevel.requiredScore) /
        (nextLevel.requiredScore - currentLevel.requiredScore);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LEVEL ${currentLevel.level}',
              style: TextStyle(
                color: theme.primary,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            Text(
              'LEVEL ${nextLevel.level}',
              style: TextStyle(
                color: theme.accent,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: theme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.primary.withOpacity(0.5)),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 20,
              width: MediaQuery.of(context).size.width * 0.85 * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primary, theme.accent],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${nextLevel.requiredScore - _currentPlayer!.score} POINTS TO NEXT LEVEL',
          style: TextStyle(
            color: theme.primary.withOpacity(0.7),
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboard(LevelTheme theme) {
    if (_allPlayers.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: theme.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.primary.withOpacity(0.5)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.leaderboard,
                size: 60,
                color: theme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'NO PLAYERS YET',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.primary.withOpacity(0.7),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _allPlayers.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final isCurrentPlayer = player.name == _currentPlayer?.name;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCurrentPlayer
                    ? [
                        theme.primary.withOpacity(0.2),
                        theme.secondary.withOpacity(0.2)
                      ]
                    : [
                        theme.surface.withOpacity(0.6),
                        theme.surface.withOpacity(0.3)
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrentPlayer
                    ? theme.primary
                    : theme.primary.withOpacity(0.3),
                width: isCurrentPlayer ? 2 : 1,
              ),
              boxShadow: isCurrentPlayer
                  ? [
                      BoxShadow(
                        color: theme.neonGlow.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: _buildRankBadge(index + 1, theme),
              title: Row(
                children: [
                  Text(
                    player.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isCurrentPlayer
                          ? theme.primary
                          : theme.primary.withOpacity(0.9),
                      letterSpacing: 1,
                    ),
                  ),
                  if (isCurrentPlayer) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.primary),
                      ),
                      child: Text(
                        'YOU',
                        style: TextStyle(
                          color: theme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Last seen: ${_formatLastPlayed(player.lastPlayed)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.primary.withOpacity(0.5),
                    ),
                  ),
                  if (player.winStreak > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Streak: ${player.winStreak}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${player.score}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.accent,
                      shadows: [
                        Shadow(
                          color: theme.accent.withOpacity(0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'POINTS',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.primary.withOpacity(0.5),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRankBadge(int rank, LevelTheme theme) {
    Color color;
    IconData icon;
    double size = 40;

    switch (rank) {
      case 1:
        color = Colors.yellow;
        icon = Icons.emoji_events;
        size = 48;
        break;
      case 2:
        color = Colors.grey[300]!;
        icon = Icons.military_tech;
        size = 44;
        break;
      case 3:
        color = Colors.orange.shade700;
        icon = Icons.military_tech;
        size = 44;
        break;
      default:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.surface.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: theme.primary.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.primary,
              ),
            ),
          ),
        );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.6,
      ),
    );
  }

  String _formatLastPlayed(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Online now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
