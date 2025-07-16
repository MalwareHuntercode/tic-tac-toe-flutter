// lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/game.dart';

/// This class handles saving and loading data
class StorageService {
  static const String _playerKey = 'current_player';
  static const String _gameHistoryKey = 'game_history';
  static const String _playersKey = 'all_players';

  // Save current player data
  static Future<void> savePlayer(Player player) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerJson = json.encode(player.toMap());
      await prefs.setString(_playerKey, playerJson);

      // Also update in all players list
      await _updatePlayerInList(player);

      print('Player saved: ${player.name} with score: ${player.score}');
    } catch (e) {
      print('Error saving player: $e');
    }
  }

  // Load current player data
  static Future<Player?> loadPlayer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playerJson = prefs.getString(_playerKey);

      if (playerJson != null) {
        final playerMap = json.decode(playerJson) as Map<String, dynamic>;
        return Player.fromMap(playerMap);
      }
      return null;
    } catch (e) {
      print('Error loading player: $e');
      return null;
    }
  }

  // Save game to history
  static Future<void> saveGame(Game game) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load existing history
      final history = await loadGameHistory();

      // Add new game at the beginning (most recent first)
      history.insert(0, game);

      // Keep only last 100 games to avoid storage issues
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }

      // Convert to JSON
      final historyJson = history.map((g) => g.toMap()).toList();
      await prefs.setString(_gameHistoryKey, json.encode(historyJson));

      print('Game saved: ${game.result} at ${game.timestamp}');
    } catch (e) {
      print('Error saving game: $e');
    }
  }

  // Load game history
  static Future<List<Game>> loadGameHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_gameHistoryKey);

      if (historyJson != null) {
        final historyList = json.decode(historyJson) as List;
        return historyList
            .map((gameMap) => Game.fromMap(gameMap as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error loading game history: $e');
      return [];
    }
  }

  // Clear game history
  static Future<void> clearGameHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_gameHistoryKey);
      print('Game history cleared');
    } catch (e) {
      print('Error clearing game history: $e');
    }
  }

  // Get all players (for leaderboard)
  static Future<List<Player>> getAllPlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playersJson = prefs.getString(_playersKey);

      if (playersJson != null) {
        final playersList = json.decode(playersJson) as List;
        return playersList
            .map((playerMap) =>
                Player.fromMap(playerMap as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error loading all players: $e');
      return [];
    }
  }

  // Update player in the all players list
  static Future<void> _updatePlayerInList(Player player) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final players = await getAllPlayers();

      // Find and update existing player or add new
      final existingIndex = players.indexWhere((p) => p.name == player.name);
      if (existingIndex >= 0) {
        players[existingIndex] = player;
      } else {
        players.add(player);
      }

      // Sort by score (highest first)
      players.sort((a, b) => b.score.compareTo(a.score));

      // Save back
      final playersJson = players.map((p) => p.toMap()).toList();
      await prefs.setString(_playersKey, json.encode(playersJson));
    } catch (e) {
      print('Error updating player in list: $e');
    }
  }

  // Get statistics for current player
  static Future<Map<String, dynamic>> getPlayerStatistics(
      String playerName) async {
    try {
      final history = await loadGameHistory();
      final playerGames =
          history.where((game) => game.playerName == playerName).toList();

      final totalGames = playerGames.length;
      final wins = playerGames.where((g) => g.result == 'win').length;
      final losses = playerGames.where((g) => g.result == 'loss').length;
      final draws = playerGames.where((g) => g.result == 'draw').length;

      // Calculate longest win streak
      int longestStreak = 0;
      int currentStreak = 0;

      for (final game in playerGames) {
        if (game.result == 'win') {
          currentStreak++;
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
        } else if (game.result == 'loss') {
          currentStreak = 0;
        }
      }

      return {
        'totalGames': totalGames,
        'wins': wins,
        'losses': losses,
        'draws': draws,
        'winRate': totalGames > 0
            ? (wins / totalGames * 100).toStringAsFixed(1)
            : '0.0',
        'longestStreak': longestStreak,
      };
    } catch (e) {
      print('Error calculating statistics: $e');
      return {
        'totalGames': 0,
        'wins': 0,
        'losses': 0,
        'draws': 0,
        'winRate': '0.0',
        'longestStreak': 0,
      };
    }
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('All data cleared');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }
}
