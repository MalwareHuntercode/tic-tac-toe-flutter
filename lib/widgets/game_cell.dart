// lib/widgets/game_cell.dart

import 'package:flutter/material.dart';

class GameCell extends StatefulWidget {
  final String value;
  final VoidCallback onTap;
  final bool isClickable;

  const GameCell({
    Key? key,
    required this.value,
    required this.onTap,
    required this.isClickable,
  }) : super(key: key);

  @override
  State<GameCell> createState() => _GameCellState();
}

class _GameCellState extends State<GameCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void didUpdateWidget(GameCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value.isEmpty && widget.value.isNotEmpty) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isClickable && widget.value.isEmpty ? widget.onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: widget.value.isEmpty ? Colors.white : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.value.isEmpty
                ? Colors.blue.shade200
                : widget.value == 'X'
                ? Colors.blue.shade400
                : Colors.red.shade400,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.value.isEmpty
                  ? Colors.blue.withOpacity(0.1)
                  : widget.value == 'X'
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: widget.value.isEmpty
            ? widget.isClickable
                  ? Center(
                      child: Icon(
                        Icons.touch_app,
                        color: Colors.grey.shade300,
                        size: 30,
                      ),
                    )
                  : const SizedBox.shrink()
            : Center(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Text(
                        widget.value,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: widget.value == 'X' ? Colors.blue : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
