// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Define named routes for navigation
      routes: {
        '/': (context) => const HomeScreen(), // Default route
        '/game': (context) => const GameScreen(), // Game screen route
        '/history': (context) => const HistoryScreen(), // History screen route
      },
      initialRoute: '/', // Start with home screen
    );
  }
}
