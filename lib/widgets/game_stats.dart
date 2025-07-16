// lib/widgets/game_stats.dart

import 'package:flutter/material.dart';

class GameStats extends StatelessWidget {
  final int totalGames;
  final int wins;
  final int losses;
  final int draws;

  const GameStats({
    Key? key,
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.draws,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final winRate = totalGames > 0
        ? (wins / totalGames * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Game Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Total', totalGames, Colors.blue),
              _buildStatItem('Wins', wins, Colors.green),
              _buildStatItem('Losses', losses, Colors.red),
              _buildStatItem('Draws', draws, Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          // Win rate progress bar
          Column(
            children: [
              Text(
                'Win Rate: $winRate%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: totalGames > 0 ? wins / totalGames : 0,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }
}
