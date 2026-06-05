import 'dart:math' as math;
import 'package:flutter/material.dart';

class SleepScoreCard extends StatefulWidget {
  const SleepScoreCard({
    super.key,
    required this.score,
    required this.status,
  });

  final int score;
  final String status;

  @override
  State<SleepScoreCard> createState() => _SleepScoreCardState();
}

class _SleepScoreCardState extends State<SleepScoreCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: widget.score.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant SleepScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _scoreAnimation = Tween<double>(
        begin: _scoreAnimation.value,
        end: widget.score.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A), // Midnight Navy
            Color(0xFF1E1E38), // Soft Navy/Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), // Purple glow
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated Circular Indicator
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, _) {
              return SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _ScoreRingPainter(
                    score: _scoreAnimation.value,
                    maxScore: 100,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 24),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFEF08A), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Sleep Score',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, _) {
                    return Text(
                      '${_scoreAnimation.value.round()} / 100',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(widget.score).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _statusColor(widget.score).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.status,
                    style: TextStyle(
                      color: _statusColor(widget.score),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(int score) {
    if (score >= 85) return const Color(0xFF34D399); // Mint Green
    if (score >= 60) return const Color(0xFFFBBF24); // Warm Gold
    return const Color(0xFFF87171); // Soft Red
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({required this.score, required this.maxScore});

  final double score;
  final double maxScore;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;

    // Background track paint
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    // Glowing arc paint
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF8B5CF6), // Soft purple
          Color(0xFFC084FC), // Lavender
          Color(0xFFFEF08A), // Moonlight yellow
          Color(0xFF8B5CF6),
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw background track circle
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    final sweepAngle = (score / maxScore) * 2 * math.pi;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2); // Start at top
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      sweepAngle,
      false,
      progressPaint,
    );
    canvas.restore();

    // Center circular badge fill
    final badgePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 8, badgePaint);
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
