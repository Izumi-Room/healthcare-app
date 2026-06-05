import 'dart:math' as math;
import 'package:flutter/material.dart';

class SleepStreakCard extends StatefulWidget {
  const SleepStreakCard({
    super.key,
    required this.streakDays,
  });

  final int streakDays;

  @override
  State<SleepStreakCard> createState() => _SleepStreakCardState();
}

class _SleepStreakCardState extends State<SleepStreakCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B).withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          // Animated Flame Painter
          SizedBox(
            width: 72,
            height: 72,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _FlamePainter(progress: _controller.value),
                );
              },
            ),
          ),
          const SizedBox(width: 20),
          // Streak Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sleep Streak',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.streakDays} Days Consecutive',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Reward pills
                const Row(
                  children: [
                    _RewardBadge(label: '+15 Tree XP', color: Color(0xFF34D399)),
                    SizedBox(width: 8),
                    _RewardBadge(label: '+10 Health XP', color: Color(0xFFC084FC)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final width = size.width;
    final height = size.height;

    // Draw fire glow background
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFEF4444).withValues(alpha: 0.15 + 0.05 * math.sin(progress * 2 * math.pi)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center.translate(0, -height * 0.35), radius: width * 0.5));
    canvas.drawCircle(center.translate(0, -height * 0.35), width * 0.5, glowPaint);

    // Wave shape calculations using sine wave based on progress
    final flicker = 3 * math.sin(progress * 2 * math.pi);

    // 1. Draw Outer Flame (Orange-Red)
    final outerPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    final outerPath = Path()
      ..moveTo(center.dx - 18, center.dy)
      ..quadraticBezierTo(center.dx - 22, center.dy - height * 0.4, center.dx - 8 + flicker, center.dy - height * 0.75)
      ..quadraticBezierTo(center.dx + flicker * 0.5, center.dy - height, center.dx + flicker, center.dy - height * 1.1)
      ..quadraticBezierTo(center.dx + 4 + flicker, center.dy - height * 0.7, center.dx + 18, center.dy - height * 0.4)
      ..quadraticBezierTo(center.dx + 18, center.dy, center.dx - 18, center.dy)
      ..close();
    canvas.drawPath(outerPath, outerPaint);

    // 2. Draw Middle Flame (Orange-Yellow)
    final midPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    final midPath = Path()
      ..moveTo(center.dx - 12, center.dy)
      ..quadraticBezierTo(center.dx - 14, center.dy - height * 0.35, center.dx - 4 - flicker, center.dy - height * 0.65)
      ..quadraticBezierTo(center.dx - flicker, center.dy - height * 0.85, center.dx - flicker * 0.5, center.dy - height * 0.95)
      ..quadraticBezierTo(center.dx + 2 + flicker, center.dy - height * 0.6, center.dx + 12, center.dy - height * 0.35)
      ..quadraticBezierTo(center.dx + 12, center.dy, center.dx - 12, center.dy)
      ..close();
    canvas.drawPath(midPath, midPaint);

    // 3. Draw Core Flame (Yellow-White)
    final corePaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..style = PaintingStyle.fill;
    final corePath = Path()
      ..moveTo(center.dx - 6, center.dy)
      ..quadraticBezierTo(center.dx - 7, center.dy - height * 0.25, center.dx - 1 + flicker * 0.3, center.dy - height * 0.45)
      ..quadraticBezierTo(center.dx + flicker * 0.2, center.dy - height * 0.6, center.dx - flicker * 0.4, center.dy - height * 0.7)
      ..quadraticBezierTo(center.dx + 1 + flicker * 0.5, center.dy - height * 0.45, center.dx + 6, center.dy - height * 0.25)
      ..quadraticBezierTo(center.dx + 6, center.dy, center.dx - 6, center.dy)
      ..close();
    canvas.drawPath(corePath, corePaint);
  }

  @override
  bool shouldRepaint(covariant _FlamePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
