// lib/screens/game_screen.dart

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game board - 3x3 grid
  // Empty string = empty cell, 'X' = player, 'O' = app
  List<List<String>> board = [
    ['', '', ''],
    ['', '', ''],
    ['', '', ''],
  ];

  // Track whose turn it is
  bool isPlayerTurn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Turn indicator
            Text(
              isPlayerTurn ? 'Your Turn (X)' : 'App\'s Turn (O)',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Game board placeholder
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: const Center(child: Text('Game Board Will Go Here')),
            ),
            const SizedBox(height: 30),

            // Reset button
            ElevatedButton(
              onPressed: () {
                // TODO: Reset the game
                print('Reset game');
              },
              child: const Text('Reset Game'),
            ),
          ],
        ),
      ),
    );
  }
}
