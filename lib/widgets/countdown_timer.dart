// lib/widgets/countdown_timer.dart

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int timeRemaining;
  final int totalTime;

  const CountdownTimer({
    Key? key,
    required this.timeRemaining,
    required this.totalTime,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.timeRemaining <= 10) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeRemaining <= 10 && oldWidget.timeRemaining > 10) {
      _animationController.repeat(reverse: true);
    } else if (widget.timeRemaining > 10) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.timeRemaining <= 10;
    final progress = widget.timeRemaining / widget.totalTime;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isUrgent ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isUrgent
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isUrgent ? Colors.red : Colors.blue).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isUrgent ? Icons.timer_off : Icons.timer,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.timeRemaining}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'seconds',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Circular progress indicator
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                      if (isUrgent)
                        const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 40,
                        ),
                    ],
                  ),
                ),
                if (isUrgent) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Hurry up!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
