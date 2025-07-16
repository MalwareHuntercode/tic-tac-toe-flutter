// lib/models/game.dart

import 'package:flutter/material.dart';

/// This class represents a single game session
class Game {
  DateTime timestamp;
  String result; // 'win', 'loss', or 'draw'
  List<List<String>> finalBoard; // The board state when game ended
  String playerName;
  int scoreChange;

  Game({
    required this.timestamp,
    required this.result,
    required this.finalBoard,
    required this.playerName,
    required this.scoreChange,
  });

  // Convert game to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'result': result,
      'finalBoard': finalBoard,
      'playerName': playerName,
      'scoreChange': scoreChange,
    };
  }

  // Create game from stored Map
  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      timestamp: DateTime.parse(map['timestamp']),
      result: map['result'],
      finalBoard: List<List<String>>.from(
        map['finalBoard'].map((row) => List<String>.from(row)),
      ),
      playerName: map['playerName'] ?? 'Player',
      scoreChange: map['scoreChange'] ?? 0,
    );
  }

  // Get formatted date string
  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  // Get result icon
  IconData getResultIcon() {
    switch (result) {
      case 'win':
        return Icons.emoji_events;
      case 'loss':
        return Icons.sentiment_dissatisfied;
      case 'draw':
        return Icons.handshake;
      default:
        return Icons.help_outline;
    }
  }

  // Get result color
  Color getResultColor() {
    switch (result) {
      case 'win':
        return Colors.green;
      case 'loss':
        return Colors.red;
      case 'draw':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
