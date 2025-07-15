// lib/models/player.dart

/// This class represents a player in our game
class Player {
  String name;
  int score;

  // Constructor - creates a new player
  Player({
    required this.name,
    this.score = 0, // Default score is 0
  });

  // Add points to score
  void addScore(int points) {
    score += points;
  }

  // Convert player to Map for storage
  Map<String, dynamic> toMap() {
    return {'name': name, 'score': score};
  }

  // Create player from stored Map
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(name: map['name'], score: map['score']);
  }
}
