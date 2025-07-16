// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tic_tac_toe_app/main.dart';
import 'package:tic_tac_toe_app/widgets/score_card.dart';

void main() {
  testWidgets('App starts with home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TicTacToeApp());

    // Verify that home screen is displayed
    expect(find.text('Welcome to Tic Tac Toe!'), findsOneWidget);
    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Can enter name and see welcome message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TicTacToeApp());

    // Enter a name
    await tester.enterText(find.byType(TextField), 'John');
    await tester.tap(find.text('Set Name'));
    await tester.pump();

    // Verify welcome message with name
    expect(find.text('Welcome back, John! 🎮'), findsOneWidget);
    expect(find.text('Start New Game'), findsOneWidget);

    // Check for ScoreCard widget instead of specific text
    expect(find.byType(ScoreCard), findsOneWidget);

    // Check that the score shows in the ScoreCard
    expect(find.text('Your Score'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Navigation to game screen works', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    // Enter name first
    await tester.enterText(find.byType(TextField), 'TestPlayer');
    await tester.tap(find.text('Set Name'));
    await tester.pump();

    // Navigate to game
    await tester.tap(find.text('Start New Game'));
    await tester.pumpAndSettle();

    // Verify game screen is displayed
    expect(find.text('Play Game'), findsOneWidget);
    expect(find.text('Your Turn (X)'), findsOneWidget);

    // Check for current score display
    expect(find.textContaining('Current Score:'), findsOneWidget);
  });

  testWidgets('Navigation to history screen works', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TicTacToeApp());

    // Enter name first
    await tester.enterText(find.byType(TextField), 'TestPlayer');
    await tester.tap(find.text('Set Name'));
    await tester.pump();

    // Navigate to history
    await tester.tap(find.text('View Game History'));
    await tester.pumpAndSettle();

    // Verify history screen is displayed
    expect(find.text('Game History'), findsOneWidget);
    // Should show summary card with statistics
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Wins'), findsOneWidget);
    expect(find.text('Losses'), findsOneWidget);
    expect(find.text('Draws'), findsOneWidget);
  });

  testWidgets('Can change player name', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    // Enter initial name
    await tester.enterText(find.byType(TextField), 'Player1');
    await tester.tap(find.text('Set Name'));
    await tester.pump();

    // Verify name is set
    expect(find.text('Welcome back, Player1! 🎮'), findsOneWidget);

    // Change player
    await tester.tap(find.text('Change Player'));
    await tester.pump();

    // Should show name input again
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Enter your name'), findsOneWidget);
  });

  testWidgets('Game screen shows player name', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    // Enter name
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.tap(find.text('Set Name'));
    await tester.pump();

    // Navigate to game
    await tester.tap(find.text('Start New Game'));
    await tester.pumpAndSettle();

    // Check that player name appears in game
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('App'), findsOneWidget);
  });
}
