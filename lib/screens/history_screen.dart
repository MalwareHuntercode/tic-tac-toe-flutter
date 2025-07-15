// lib/screens/history_screen.dart

import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: This will be replaced with actual game history
    final List<Map<String, String>> dummyHistory = [
      {'date': '25/7/2025 at 14:30', 'result': 'Win'},
      {'date': '24/7/2025 at 10:15', 'result': 'Loss'},
      {'date': '23/7/2025 at 18:45', 'result': 'Draw'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: dummyHistory.isEmpty
          ? const Center(
              child: Text(
                'No games played yet!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: dummyHistory.length,
              itemBuilder: (context, index) {
                final game = dummyHistory[index];
                return ListTile(
                  leading: Icon(
                    game['result'] == 'Win'
                        ? Icons.emoji_events
                        : game['result'] == 'Loss'
                        ? Icons.sentiment_dissatisfied
                        : Icons.handshake,
                    color: game['result'] == 'Win'
                        ? Colors.green
                        : game['result'] == 'Loss'
                        ? Colors.red
                        : Colors.orange,
                  ),
                  title: Text('${game['result']}'),
                  subtitle: Text(game['date']!),
                );
              },
            ),
    );
  }
}
