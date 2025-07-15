// lib/widgets/app_logo.dart

import 'package:flutter/material.dart';

class AppLogo extends StatefulWidget {
  final double size;
  final bool animate;

  const AppLogo({Key? key, this.size = 60, this.animate = true})
    : super(key: key);

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );

      _rotationAnimation = Tween<double>(
        begin: 0,
        end: 2 * 3.14159,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _scaleAnimation = Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Grid pattern
          Icon(
            Icons.grid_on,
            size: widget.size * 0.6,
            color: Colors.blue.shade600,
          ),
          // X and O overlay
          Positioned(
            top: widget.size * 0.15,
            left: widget.size * 0.15,
            child: Text(
              'X',
              style: TextStyle(
                fontSize: widget.size * 0.25,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            bottom: widget.size * 0.15,
            right: widget.size * 0.15,
            child: Text(
              'O',
              style: TextStyle(
                fontSize: widget.size * 0.25,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (!widget.animate) {
      return logo;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: logo),
        );
      },
    );
  }
}
