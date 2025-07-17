// lib/widgets/cyberpunk_game_board.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/cyberpunk_theme.dart';

class CyberpunkGameBoard extends StatefulWidget {
  final List<List<String>> board;
  final Function(int, int) onCellTap;
  final bool isPlayerTurn;
  final List<int>? hintCell;
  final int level;

  const CyberpunkGameBoard({
    Key? key,
    required this.board,
    required this.onCellTap,
    required this.isPlayerTurn,
    this.hintCell,
    required this.level,
  }) : super(key: key);

  @override
  State<CyberpunkGameBoard> createState() => _CyberpunkGameBoardState();
}

class _CyberpunkGameBoardState extends State<CyberpunkGameBoard>
    with TickerProviderStateMixin {
  late AnimationController _glitchController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Random glitch effect
    _startRandomGlitch();
  }

  void _startRandomGlitch() {
    Future.delayed(Duration(seconds: 3 + math.Random().nextInt(5)), () {
      if (mounted) {
        _glitchController.forward().then((_) {
          _glitchController.reverse();
        });
        _startRandomGlitch();
      }
    });
  }

  @override
  void dispose() {
    _glitchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CyberpunkTheme.levelThemes[
        (widget.level - 1).clamp(0, CyberpunkTheme.levelThemes.length - 1)];

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primary.withOpacity(0.3),
                theme.secondary.withOpacity(0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.neonGlow.withOpacity(0.5 * _pulseAnimation.value),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.primary,
                width: 2,
              ),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  // Grid lines
                  CustomPaint(
                    size: Size.infinite,
                    painter: _GridPainter(theme.primary.withOpacity(0.3)),
                  ),
                  // Game cells
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final row = index ~/ 3;
                      final col = index % 3;
                      final cellValue = widget.board[row][col];
                      final isHint = widget.hintCell != null &&
                          widget.hintCell![0] == row &&
                          widget.hintCell![1] == col;

                      return _CyberpunkCell(
                        value: cellValue,
                        onTap: () => widget.onCellTap(row, col),
                        isClickable: widget.isPlayerTurn && cellValue.isEmpty,
                        isHint: isHint,
                        theme: theme,
                        glitchAnimation: _glitchController,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CyberpunkCell extends StatefulWidget {
  final String value;
  final VoidCallback onTap;
  final bool isClickable;
  final bool isHint;
  final LevelTheme theme;
  final AnimationController glitchAnimation;

  const _CyberpunkCell({
    Key? key,
    required this.value,
    required this.onTap,
    required this.isClickable,
    required this.isHint,
    required this.theme,
    required this.glitchAnimation,
  }) : super(key: key);

  @override
  State<_CyberpunkCell> createState() => _CyberpunkCellState();
}

class _CyberpunkCellState extends State<_CyberpunkCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(_CyberpunkCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value.isEmpty && widget.value.isNotEmpty) {
      _scaleController.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isClickable ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: widget.glitchAnimation,
        builder: (context, child) {
          final offset = widget.glitchAnimation.value * 2;
          return Transform.translate(
            offset: Offset(
              math.Random().nextDouble() * offset - offset / 2,
              math.Random().nextDouble() * offset - offset / 2,
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: widget.value.isEmpty
                    ? widget.theme.surface.withOpacity(0.3)
                    : widget.theme.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: widget.isHint
                      ? Colors.yellow
                      : widget.value.isEmpty
                          ? widget.theme.primary.withOpacity(0.3)
                          : widget.value == 'X'
                              ? widget.theme.primary
                              : widget.theme.accent,
                  width: widget.isHint ? 3 : 2,
                ),
                boxShadow: [
                  if (widget.value.isNotEmpty)
                    BoxShadow(
                      color: (widget.value == 'X'
                              ? widget.theme.primary
                              : widget.theme.accent)
                          .withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: widget.value.isEmpty
                  ? (widget.isClickable
                      ? Center(
                          child: Icon(
                            Icons.add,
                            color: widget.theme.primary.withOpacity(0.3),
                            size: 30,
                          ),
                        )
                      : const SizedBox.shrink())
                  : Center(
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: _NeonText(
                              text: widget.value,
                              color: widget.value == 'X'
                                  ? widget.theme.primary
                                  : widget.theme.accent,
                              fontSize: 48,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _NeonText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const _NeonText({
    Key? key,
    required this.text,
    required this.color,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glow layers
        for (int i = 0; i < 3; i++)
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.1),
              shadows: [
                Shadow(
                  color: color,
                  blurRadius: (i + 1) * 10.0,
                ),
              ],
            ),
          ),
        // Main text
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: [
              Shadow(
                color: color,
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (int i = 1; i < 3; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(size.width * i / 3, 0),
        Offset(size.width * i / 3, size.height),
        paint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(0, size.height * i / 3),
        Offset(size.width, size.height * i / 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
