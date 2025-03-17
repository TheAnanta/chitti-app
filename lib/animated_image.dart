import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedImageEntry extends StatefulWidget {
  final Widget child;
  const AnimatedImageEntry({super.key, required this.child});
  @override
  State<AnimatedImageEntry> createState() => _AnimatedImageEntryState();
}

class _AnimatedImageEntryState extends State<AnimatedImageEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation, _translationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Animation duration
    );

    _rotationAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ), // Curve for smooth animation
    );
    _translationAnimation = Tween<double>(begin: 96, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ), // Curve for smooth animation
    );

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: (96 - _translationAnimation.value) / 96,
          child: Transform.translate(
            offset: Offset(-96 * (_translationAnimation.value / 96), 0),
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * math.pi,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
