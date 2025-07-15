// lib/services/storage_service.dart

import '../models/player.dart';
import '../models/game.dart';

/// This class handles saving and loading data
class StorageService {
  // TODO: We'll implement actual storage in Phase 5
  // For now, these are placeholder methods

  // Save player data
  static Future<void> savePlayer(Player player) async {
    print('Saving player: ${player.name} with score: ${player.score}');
    // TODO: Implement actual storage
  }

  // Load player data
  static Future<Player?> loadPlayer() async {
    print('Loading player data...');
    // TODO: Implement actual storage
    return null;
  }

  // Save game to history
  static Future<void> saveGame(Game game) async {
    print('Saving game: ${game.result} at ${game.timestamp}');
    // TODO: Implement actual storage
  }

  // Load game history
  static Future<List<Game>> loadGameHistory() async {
    print('Loading game history...');
    // TODO: Implement actual storage
    return [];
  }
}
