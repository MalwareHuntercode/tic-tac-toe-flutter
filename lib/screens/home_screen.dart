// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../widgets/score_card.dart';
import '../widgets/app_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This will hold our player name and score
  String playerName = '';
  int playerScore = 0;
  int winStreak = 0;
  bool useTimer = true; // Timer setting

  // Controller for the text field
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Tic Tac Toe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              const AppLogo(size: 100),
              const SizedBox(height: 30),

              // Welcome message
              Text(
                playerName.isEmpty
                    ? 'Welcome to Tic Tac Toe!'
                    : 'Welcome back, $playerName! 🎮',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Name input field (show only if name is empty)
              if (playerName.isEmpty) ...[
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Enter your name',
                          hintText: 'e.g., John',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              playerName = value.trim();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_nameController.text.trim().isNotEmpty) {
                            setState(() {
                              playerName = _nameController.text.trim();
                            });
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Set Name'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],

              // Score display using our custom widget
              if (playerName.isNotEmpty) ...[
                ScoreCard(score: playerScore),
                const SizedBox(height: 16),

                // Win streak display
                if (winStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Win Streak: $winStreak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
              ],

              // Start game button (show only if name is set)
              if (playerName.isNotEmpty) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to game screen with current score and name
                    Navigator.pushNamed(
                      context,
                      '/game',
                      arguments: {
                        'score': playerScore,
                        'playerName': playerName,
                        'winStreak': winStreak,
                        'useTimer': useTimer,
                      },
                    ).then((result) {
                      // Update score and streak when returning from game
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          // Ensure scoreChange is treated as int
                          final scoreChange =
                              result['scoreChange'] as int? ?? 0;
                          playerScore += scoreChange;

                          // Update win streak
                          if (result['gameResult'] == 'win') {
                            winStreak++;
                          } else if (result['gameResult'] == 'loss') {
                            winStreak = 0; // Reset streak on loss
                          }
                          // Draw doesn't affect streak
                        });
                      }
                    });
                  },
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    'Start New Game',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
                const SizedBox(height: 16),

                // History button
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to history screen
                    Navigator.pushNamed(context, '/history');
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View Game History'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Timer toggle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text('30s Timer'),
                      const SizedBox(width: 8),
                      Switch(
                        value: useTimer,
                        onChanged: (value) {
                          setState(() {
                            useTimer = value;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Change name button
                TextButton(
                  onPressed: () {
                    setState(() {
                      playerName = '';
                      playerScore = 0;
                      winStreak = 0;
                      _nameController.clear();
                    });
                  },
                  child: const Text('Change Player'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
