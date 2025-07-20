// lib/screens/game_analysis_screen.dart

import 'package:flutter/material.dart';
import '../services/game_analyzer.dart';
import '../theme/cyberpunk_theme.dart';
import '../widgets/cyberpunk_game_board.dart';

class GameAnalysisScreen extends StatefulWidget {
  final GameAnalysis analysis;
  final List<GameMove> moveHistory;
  final int level;

  const GameAnalysisScreen({
    Key? key,
    required this.analysis,
    required this.moveHistory,
    required this.level,
  }) : super(key: key);

  @override
  State<GameAnalysisScreen> createState() => _GameAnalysisScreenState();
}

class _GameAnalysisScreenState extends State<GameAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentMoveIndex = 0;
  List<List<String>> _displayBoard = [
    ['', '', ''],
    ['', '', ''],
    ['', '', ''],
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateBoardToMove(int moveIndex) {
    setState(() {
      _currentMoveIndex = moveIndex;
      _displayBoard = [
        ['', '', ''],
        ['', '', ''],
        ['', '', ''],
      ];

      // Apply all moves up to the current index
      for (int i = 0; i <= moveIndex && i < widget.moveHistory.length; i++) {
        final move = widget.moveHistory[i];
        _displayBoard[move.row][move.col] = move.player;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CyberpunkTheme.levelThemes[
        (widget.level - 1).clamp(0, CyberpunkTheme.levelThemes.length - 1)];

    // Get the analysis for the current player move
    final playerMoveIndex = _currentMoveIndex ~/ 2;
    final currentAnalysis =
        playerMoveIndex < widget.analysis.moveAnalyses.length
            ? widget.analysis.moveAnalyses[playerMoveIndex]
            : null;

    return Theme(
      data: CyberpunkTheme.getTheme(widget.level),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GAME ANALYSIS'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Performance Score
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primary.withOpacity(0.2),
                      theme.secondary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.primary, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'PERFORMANCE SCORE',
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: widget.analysis.performanceScore / 100,
                            strokeWidth: 8,
                            backgroundColor: theme.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(
                                  widget.analysis.performanceScore, theme),
                            ),
                          ),
                        ),
                        Text(
                          '${widget.analysis.performanceScore}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(
                                widget.analysis.performanceScore, theme),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.analysis.summary,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.primary.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Move Stats
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.primary.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Perfect', widget.analysis.perfectMoves,
                        Colors.green, theme),
                    _buildStatItem('Mistakes', widget.analysis.mistakes,
                        Colors.orange, theme),
                    _buildStatItem('Blunders', widget.analysis.blunders,
                        Colors.red, theme),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Game Board
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Game Board
                      CyberpunkGameBoard(
                        board: _displayBoard,
                        onCellTap: (_, __) {}, // Non-interactive
                        isPlayerTurn: false,
                        level: widget.level,
                        hintCell: currentAnalysis?.bestMove != null &&
                                    currentAnalysis?.move.row !=
                                        currentAnalysis?.bestMove.row ||
                                currentAnalysis?.move.col !=
                                    currentAnalysis?.bestMove.col
                            ? [
                                currentAnalysis!.bestMove.row,
                                currentAnalysis.bestMove.col
                              ]
                            : null,
                      ),

                      const SizedBox(height: 20),

                      // Move Navigation
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.skip_previous,
                                  color: theme.primary),
                              onPressed: _currentMoveIndex > 0
                                  ? () =>
                                      _updateBoardToMove(_currentMoveIndex - 1)
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: theme.primary),
                              ),
                              child: Text(
                                'Move ${_currentMoveIndex + 1} / ${widget.moveHistory.length}',
                                style: TextStyle(color: theme.primary),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_next, color: theme.primary),
                              onPressed: _currentMoveIndex <
                                      widget.moveHistory.length - 1
                                  ? () =>
                                      _updateBoardToMove(_currentMoveIndex + 1)
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      // Move Analysis
                      if (currentAnalysis != null)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getMoveQualityColor(currentAnalysis.quality)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  _getMoveQualityColor(currentAnalysis.quality),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getMoveQualityIcon(
                                        currentAnalysis.quality),
                                    color: _getMoveQualityColor(
                                        currentAnalysis.quality),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getMoveQualityText(
                                        currentAnalysis.quality),
                                    style: TextStyle(
                                      color: _getMoveQualityColor(
                                          currentAnalysis.quality),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentAnalysis.explanation,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.primary.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16), // Add some bottom padding
                    ],
                  ),
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('CONTINUE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, int value, Color color, LevelTheme theme) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.primary.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score, LevelTheme theme) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return theme.primary;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _getMoveQualityColor(MoveQuality quality) {
    switch (quality) {
      case MoveQuality.perfect:
        return Colors.green;
      case MoveQuality.good:
        return Colors.blue;
      case MoveQuality.mistake:
        return Colors.orange;
      case MoveQuality.blunder:
        return Colors.red;
    }
  }

  IconData _getMoveQualityIcon(MoveQuality quality) {
    switch (quality) {
      case MoveQuality.perfect:
        return Icons.star;
      case MoveQuality.good:
        return Icons.thumb_up;
      case MoveQuality.mistake:
        return Icons.warning;
      case MoveQuality.blunder:
        return Icons.error;
    }
  }

  String _getMoveQualityText(MoveQuality quality) {
    switch (quality) {
      case MoveQuality.perfect:
        return 'PERFECT MOVE';
      case MoveQuality.good:
        return 'GOOD MOVE';
      case MoveQuality.mistake:
        return 'MISTAKE';
      case MoveQuality.blunder:
        return 'BLUNDER';
    }
  }
}
