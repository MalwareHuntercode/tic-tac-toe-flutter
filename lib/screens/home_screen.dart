// lib/screens/home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This will hold our player name and score
  String playerName = '';
  int playerScore = 0;

  // Controller for the text field
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              Text(
                playerName.isEmpty ? 'Welcome!' : 'Welcome, $playerName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Name input field (show only if name is empty)
              if (playerName.isEmpty) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        playerName = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      setState(() {
                        playerName = _nameController.text;
                      });
                    }
                  },
                  child: const Text('Set Name'),
                ),
                const SizedBox(height: 20),
              ],

              // Score display
              Text('Score: $playerScore', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 40),

              // Start game button
              ElevatedButton(
                onPressed: () {
                  // Navigate to game screen
                  Navigator.pushNamed(context, '/game');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Start New Game',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),

              // History button
              TextButton(
                onPressed: () {
                  // Navigate to history screen
                  Navigator.pushNamed(context, '/history');
                },
                child: const Text('View Game History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
