import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class LeafParticleLayer extends StatefulWidget {
  const LeafParticleLayer({
    super.key,
    required this.active,
    required this.blossoms,
  });

  final bool active;
  final bool blossoms;

  @override
  State<LeafParticleLayer> createState() => _LeafParticleLayerState();
}

class _LeafParticleLayerState extends State<LeafParticleLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.xslow,
    );
    if (widget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant LeafParticleLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && widget.active != oldWidget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: LeafParticlePainter(
              progress: _controller.value,
              blossoms: widget.blossoms,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class LeafParticlePainter extends CustomPainter {
  const LeafParticlePainter({
    required this.progress,
    required this.blossoms,
  });

  final double progress;
  final bool blossoms;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 18; i++) {
      final seed = i * 37.0;
      final x = size.width * (.25 + (math.sin(seed) + 1) * .25);
      final drift = math.sin(progress * math.pi + i) * 36;
      final y = size.height * (.20 + progress * .58) + (i % 5) * 9;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      paint.color = (blossoms ? AppColors.pink200 : AppColors.green400)
          .withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x + drift, y);
      canvas.rotate(progress * math.pi + i);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: blossoms ? 9 : 12,
        height: blossoms ? 8 : 16,
      );
      canvas.drawOval(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant LeafParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.blossoms != blossoms;
  }
}
