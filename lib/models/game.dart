// lib/models/game.dart

/// This class represents a single game session
class Game {
  DateTime timestamp;
  String result; // 'win', 'loss', or 'draw'
  List<List<String>> finalBoard; // The board state when game ended

  Game({
    required this.timestamp,
    required this.result,
    required this.finalBoard,
  });

  // Convert game to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'result': result,
      'finalBoard': finalBoard,
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
    );
  }

  // Get formatted date string
  String getFormattedDate() {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
