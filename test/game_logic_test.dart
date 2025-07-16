// test/game_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/services/game_logic.dart';

void main() {
  group('GameLogic Tests', () {
    test('checkWinner detects horizontal wins', () {
      final board = [
        ['X', 'X', 'X'],
        ['O', 'O', ''],
        ['', '', ''],
      ];
      expect(GameLogic.checkWinner(board), 'X');
    });

    test('checkWinner detects vertical wins', () {
      final board = [
        ['O', 'X', ''],
        ['O', 'X', ''],
        ['O', '', ''],
      ];
      expect(GameLogic.checkWinner(board), 'O');
    });

    test('checkWinner detects diagonal wins', () {
      final board = [
        ['X', 'O', ''],
        ['O', 'X', ''],
        ['', '', 'X'],
      ];
      expect(GameLogic.checkWinner(board), 'X');
    });

    test('checkWinner returns empty string when no winner', () {
      final board = [
        ['X', 'O', 'X'],
        ['O', 'X', 'O'],
        ['O', 'X', ''],
      ];
      expect(GameLogic.checkWinner(board), '');
    });

    test('isBoardFull correctly identifies full board', () {
      final fullBoard = [
        ['X', 'O', 'X'],
        ['O', 'X', 'O'],
        ['O', 'X', 'X'],
      ];
      expect(GameLogic.isBoardFull(fullBoard), true);

      final notFullBoard = [
        ['X', 'O', 'X'],
        ['O', '', 'O'],
        ['O', 'X', 'X'],
      ];
      expect(GameLogic.isBoardFull(notFullBoard), false);
    });

    test('makeAppMove returns valid move', () {
      final board = [
        ['X', '', ''],
        ['', 'O', ''],
        ['', '', 'X'],
      ];

      final move = GameLogic.makeAppMove(board);
      expect(move, isNotNull);
      expect(move!.length, 2);
      expect(board[move[0]][move[1]], '');
    });

    test('makeAppMove blocks player win', () {
      final board = [
        ['X', 'X', ''],
        ['O', '', ''],
        ['', '', ''],
      ];

      final move = GameLogic.makeAppMove(board, difficulty: 'hard');
      expect(move, [0, 2]); // Should block the win
    });

    test('makeAppMove takes winning move', () {
      final board = [
        ['O', 'O', ''],
        ['X', 'X', ''],
        ['', '', ''],
      ];

      final move = GameLogic.makeAppMove(board, difficulty: 'hard');
      expect(move, [0, 2]); // Should win the game
    });

    test('getHint provides good suggestions', () {
      final board = [
        ['X', 'X', ''],
        ['O', '', ''],
        ['', '', ''],
      ];

      final hint = GameLogic.getHint(board);
      expect(hint, [0, 2]); // Should suggest blocking
    });
  });
}
