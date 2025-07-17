// lib/screens/cyberpunk_home_screen.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/player.dart';
import '../models/difficulty_level.dart';
import '../services/storage_service.dart';
import '../theme/cyberpunk_theme.dart';
import '../widgets/app_logo.dart';

class CyberpunkHomeScreen extends StatefulWidget {
  const CyberpunkHomeScreen({Key? key}) : super(key: key);

  @override
  State<CyberpunkHomeScreen> createState() => _CyberpunkHomeScreenState();
}

class _CyberpunkHomeScreenState extends State<CyberpunkHomeScreen>
    with TickerProviderStateMixin {
  // Player data
  String playerName = '';
  int playerScore = 0;
  int winStreak = 0;
  int currentLevel = 1;
  bool useTimer = true;

  // Controllers
  final TextEditingController _nameController = TextEditingController();

  // Loading state
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _glitchController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Current player
  Player? _currentPlayer;

  @override
  void initState() {
    super.initState();
    _loadPlayerData();

    // Initialize animations
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

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

    _startRandomGlitch();
  }

  void _startRandomGlitch() {
    Future.delayed(Duration(seconds: 3 + math.Random().nextInt(5)), () {
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
    _nameController.dispose();
    _glitchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Load player data from storage
  Future<void> _loadPlayerData() async {
    final player = await StorageService.loadPlayer();
    if (player != null && mounted) {
      setState(() {
        _currentPlayer = player;
        playerName = player.name;
        playerScore = player.score;
        winStreak = player.winStreak;
        currentLevel = DifficultyLevel.getCurrentLevel(player.score).level;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save player data
  Future<void> _savePlayerData() async {
    if (playerName.isNotEmpty) {
      final player = Player(
        name: playerName,
        score: playerScore,
        winStreak: winStreak,
        currentLevel: currentLevel,
      );
      await StorageService.savePlayer(player);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CyberpunkTheme.levelThemes[
        (currentLevel - 1).clamp(0, CyberpunkTheme.levelThemes.length - 1)];
    final difficulty = DifficultyLevel.getCurrentLevel(playerScore);
    final nextLevel = DifficultyLevel.getNextLevel(playerScore);

    return Theme(
      data: CyberpunkTheme.getTheme(currentLevel),
      child: Scaffold(
        backgroundColor: theme.background,
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Title with glitch effect
                        AnimatedBuilder(
                          animation: _glitchController,
                          builder: (context, child) {
                            final offset = _glitchController.value * 5;
                            return Stack(
                              children: [
                                // Glitch layers
                                Transform.translate(
                                  offset: Offset(offset, 0),
                                  child: Text(
                                    'TIC TAC TOE',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: theme.accent.withOpacity(0.5),
                                      letterSpacing: 8,
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset: Offset(-offset, 0),
                                  child: Text(
                                    'TIC TAC TOE',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: theme.secondary.withOpacity(0.5),
                                      letterSpacing: 8,
                                    ),
                                  ),
                                ),
                                // Main text
                                Text(
                                  'TIC TAC TOE',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primary,
                                    letterSpacing: 8,
                                    shadows: [
                                      Shadow(
                                        color: theme.neonGlow,
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'CYBERPUNK EDITION',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.accent,
                            letterSpacing: 4,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Player section
                        if (playerName.isEmpty) ...[
                          _buildNameInput(theme),
                        ] else ...[
                          _buildPlayerInfo(theme, difficulty, nextLevel),
                        ],

                        const SizedBox(height: 40),

                        // Action buttons
                        if (playerName.isNotEmpty) ...[
                          _buildActionButtons(theme),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNameInput(LevelTheme theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.surface.withOpacity(0.8),
                theme.surface.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.primary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.neonGlow.withOpacity(0.3 * _pulseAnimation.value),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'ENTER YOUR CODENAME',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                style: TextStyle(color: theme.primary),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g., CyberWarrior',
                  hintStyle: TextStyle(color: theme.primary.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.person, color: theme.primary),
                  filled: true,
                  fillColor: theme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: theme.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide:
                        BorderSide(color: theme.primary.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: theme.primary, width: 2),
                  ),
                ),
                onSubmitted: (value) async {
                  if (value.trim().isNotEmpty) {
                    await _setPlayerName(value.trim());
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_nameController.text.trim().isNotEmpty) {
                    await _setPlayerName(_nameController.text.trim());
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('INITIALIZE'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setPlayerName(String name) async {
    // Check if player exists
    final players = await StorageService.getAllPlayers();
    final existingPlayer = players.firstWhere(
      (p) => p.name == name,
      orElse: () => Player(name: name),
    );

    setState(() {
      playerName = existingPlayer.name;
      playerScore = existingPlayer.score;
      winStreak = existingPlayer.winStreak;
      currentLevel =
          DifficultyLevel.getCurrentLevel(existingPlayer.score).level;
      _currentPlayer = existingPlayer;
    });
    _savePlayerData();
  }

  Widget _buildPlayerInfo(LevelTheme theme, DifficultyLevel difficulty,
      DifficultyLevel? nextLevel) {
    return Column(
      children: [
        // Player card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primary.withOpacity(0.2),
                theme.secondary.withOpacity(0.2)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.primary, width: 2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, color: theme.primary, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    playerName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stats grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('SCORE', playerScore.toString(), theme),
                  _buildStatItem('LEVEL', difficulty.level.toString(), theme),
                  if (winStreak > 0)
                    _buildStatItem('STREAK', '$winStreak🔥', theme)
                  else
                    _buildStatItem(
                        'GAMES',
                        _currentPlayer?.totalGamesPlayed.toString() ?? '0',
                        theme),
                ],
              ),

              const SizedBox(height: 20),

              // Level progress
              if (nextLevel != null) ...[
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          difficulty.name,
                          style: TextStyle(color: theme.primary, fontSize: 14),
                        ),
                        Text(
                          nextLevel.name,
                          style: TextStyle(color: theme.accent, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (playerScore - difficulty.requiredScore) /
                          (nextLevel.requiredScore - difficulty.requiredScore),
                      minHeight: 8,
                      backgroundColor: theme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${nextLevel.requiredScore - playerScore} points to Level ${nextLevel.level}',
                      style: TextStyle(
                        color: theme.primary.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.yellow),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.star, color: Colors.yellow),
                      SizedBox(width: 8),
                      Text(
                        'MAX LEVEL ACHIEVED!',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.star, color: Colors.yellow),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Timer toggle
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.primary.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer, color: theme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'TIME LIMIT (${difficulty.moveTimeLimit}s)',
                    style: TextStyle(color: theme.primary),
                  ),
                ],
              ),
              Switch(
                value: useTimer,
                onChanged: (value) {
                  setState(() {
                    useTimer = value;
                  });
                },
                activeColor: theme.primary,
                activeTrackColor: theme.primary.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, LevelTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.primary.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.primary.withOpacity(0.7),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(LevelTheme theme) {
    return Column(
      children: [
        // Play button
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color:
                        theme.primary.withOpacity(0.5 * _pulseAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/cyberpunk-game',
                    arguments: {
                      'score': playerScore,
                      'playerName': playerName,
                      'winStreak': winStreak,
                      'useTimer': useTimer,
                      'currentLevel': currentLevel,
                    },
                  ).then((result) {
                    if (result != null && result is Map<String, dynamic>) {
                      setState(() {
                        final scoreChange = result['scoreChange'] as int? ?? 0;
                        playerScore += scoreChange;

                        if (result['gameResult'] == 'win') {
                          winStreak++;
                        } else if (result['gameResult'] == 'loss') {
                          winStreak = 0;
                        }

                        // Update level
                        currentLevel =
                            DifficultyLevel.getCurrentLevel(playerScore).level;

                        // Update player
                        if (_currentPlayer != null) {
                          _currentPlayer!.score = playerScore;
                          _currentPlayer!.winStreak = winStreak;
                          _currentPlayer!.currentLevel = currentLevel;
                          _currentPlayer!.totalGamesPlayed++;
                        }
                      });

                      _savePlayerData();
                    }
                  });
                },
                icon: const Icon(Icons.play_arrow, size: 32),
                label: const Text(
                  'START GAME',
                  style: TextStyle(fontSize: 20, letterSpacing: 2),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: theme.primary,
                  foregroundColor: theme.background,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Secondary buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/history'),
                icon: const Icon(Icons.history),
                label: const Text('HISTORY'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/statistics'),
                icon: const Icon(Icons.leaderboard),
                label: const Text('STATS'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Logout button
        TextButton.icon(
          onPressed: () async {
            await _savePlayerData();
            setState(() {
              playerName = '';
              playerScore = 0;
              winStreak = 0;
              currentLevel = 1;
              _nameController.clear();
              _currentPlayer = null;
            });
          },
          icon: const Icon(Icons.logout),
          label: const Text('CHANGE PLAYER'),
          style: TextButton.styleFrom(
            foregroundColor: theme.primary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
