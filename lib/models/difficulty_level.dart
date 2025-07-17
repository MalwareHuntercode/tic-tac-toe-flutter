// lib/models/difficulty_level.dart

class DifficultyLevel {
  final int level;
  final String name;
  final String description;
  final int requiredScore;
  final double aiStrength; // 0.0 to 1.0
  final bool showHints;
  final int moveTimeLimit;
  final Map<String, dynamic> aiSettings;

  const DifficultyLevel({
    required this.level,
    required this.name,
    required this.description,
    required this.requiredScore,
    required this.aiStrength,
    required this.showHints,
    required this.moveTimeLimit,
    required this.aiSettings,
  });

  static const List<DifficultyLevel> levels = [
    DifficultyLevel(
      level: 1,
      name: 'Neon Rookie',
      description: 'Learn the basics in the neon-lit streets',
      requiredScore: 0,
      aiStrength: 0.2,
      showHints: true,
      moveTimeLimit: 45,
      aiSettings: {
        'randomMoveChance': 0.7,
        'mistakeChance': 0.3,
        'lookAhead': 0,
      },
    ),
    DifficultyLevel(
      level: 2,
      name: 'Digital Warrior',
      description: 'Face smarter AI in the digital realm',
      requiredScore: 50,
      aiStrength: 0.4,
      showHints: true,
      moveTimeLimit: 30,
      aiSettings: {
        'randomMoveChance': 0.4,
        'mistakeChance': 0.2,
        'lookAhead': 1,
      },
    ),
    DifficultyLevel(
      level: 3,
      name: 'Matrix Master',
      description: 'Navigate the matrix against clever opponents',
      requiredScore: 150,
      aiStrength: 0.6,
      showHints: false,
      moveTimeLimit: 20,
      aiSettings: {
        'randomMoveChance': 0.2,
        'mistakeChance': 0.1,
        'lookAhead': 2,
      },
    ),
    DifficultyLevel(
      level: 4,
      name: 'System Override',
      description: 'Challenge the system with limited time',
      requiredScore: 300,
      aiStrength: 0.8,
      showHints: false,
      moveTimeLimit: 15,
      aiSettings: {
        'randomMoveChance': 0.1,
        'mistakeChance': 0.05,
        'lookAhead': 3,
      },
    ),
    DifficultyLevel(
      level: 5,
      name: 'Cyber Legend',
      description: 'Face the ultimate AI - near perfect play',
      requiredScore: 500,
      aiStrength: 0.95,
      showHints: false,
      moveTimeLimit: 10,
      aiSettings: {
        'randomMoveChance': 0.05,
        'mistakeChance': 0.01,
        'lookAhead': 4,
        'useMinimax': true,
      },
    ),
  ];

  static DifficultyLevel getCurrentLevel(int score) {
    DifficultyLevel currentLevel = levels.first;

    for (final level in levels) {
      if (score >= level.requiredScore) {
        currentLevel = level;
      } else {
        break;
      }
    }

    return currentLevel;
  }

  static DifficultyLevel? getNextLevel(int score) {
    final current = getCurrentLevel(score);
    if (current.level < levels.length) {
      return levels[current.level]; // Next level is at index current.level
    }
    return null;
  }

  int getPointsToNextLevel(int currentScore) {
    final nextLevel = getNextLevel(currentScore);
    if (nextLevel != null) {
      return nextLevel.requiredScore - currentScore;
    }
    return 0;
  }
}
