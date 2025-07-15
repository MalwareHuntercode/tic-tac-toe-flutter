// lib/screens/history_screen.dart

import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: This will be replaced with actual game history from storage
    final List<Map<String, String>> dummyHistory = [
      {'date': '25/7/2025 at 14:30', 'result': 'Win'},
      {'date': '24/7/2025 at 10:15', 'result': 'Loss'},
      {'date': '23/7/2025 at 18:45', 'result': 'Draw'},
      {'date': '23/7/2025 at 16:20', 'result': 'Win'},
      {'date': '22/7/2025 at 20:10', 'result': 'Win'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Game History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: dummyHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No games played yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start playing to see your history here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryItem(
                        'Total',
                        dummyHistory.length.toString(),
                        Colors.blue,
                      ),
                      _buildSummaryItem(
                        'Wins',
                        dummyHistory
                            .where((g) => g['result'] == 'Win')
                            .length
                            .toString(),
                        Colors.green,
                      ),
                      _buildSummaryItem(
                        'Losses',
                        dummyHistory
                            .where((g) => g['result'] == 'Loss')
                            .length
                            .toString(),
                        Colors.red,
                      ),
                      _buildSummaryItem(
                        'Draws',
                        dummyHistory
                            .where((g) => g['result'] == 'Draw')
                            .length
                            .toString(),
                        Colors.orange,
                      ),
                    ],
                  ),
                ),

                // History list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: dummyHistory.length,
                    itemBuilder: (context, index) {
                      final game = dummyHistory[index];
                      return _buildHistoryCard(
                        game,
                        index,
                        dummyHistory.length,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildHistoryCard(
    Map<String, String> game,
    int index,
    int totalGames,
  ) {
    final result = game['result']!;
    final color = result == 'Win'
        ? Colors.green
        : result == 'Loss'
        ? Colors.red
        : Colors.orange;

    final icon = result == 'Win'
        ? Icons.emoji_events
        : result == 'Loss'
        ? Icons.sentiment_dissatisfied
        : Icons.handshake;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          'Game #${totalGames - index}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          game['date']!,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            result,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
