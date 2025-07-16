// lib/models/player.dart

/// This class represents a player in our game
class Player {
  String name;
  int score;
  int winStreak;
  DateTime lastPlayed;

  // Constructor - creates a new player
  Player({
    required this.name,
    this.score = 0,
    this.winStreak = 0,
    DateTime? lastPlayed,
  }) : lastPlayed = lastPlayed ?? DateTime.now();

  // Add points to score
  void addScore(int points) {
    score += points;
    lastPlayed = DateTime.now();
  }

  // Update win streak
  void updateStreak(String gameResult) {
    if (gameResult == 'win') {
      winStreak++;
    } else if (gameResult == 'loss') {
      winStreak = 0;
    }
    // Draw doesn't affect streak
    lastPlayed = DateTime.now();
  }

  // Convert player to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'score': score,
      'winStreak': winStreak,
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  // Create player from stored Map
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      name: map['name'] ?? '',
      score: map['score'] ?? 0,
      winStreak: map['winStreak'] ?? 0,
      lastPlayed: map['lastPlayed'] != null
          ? DateTime.parse(map['lastPlayed'])
          : DateTime.now(),
    );
  }
}
