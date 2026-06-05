import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/sleep_record.dart';

class WeeklySleepGarden extends StatefulWidget {
  const WeeklySleepGarden({super.key, required this.records});

  final List<SleepRecord> records;

  @override
  State<WeeklySleepGarden> createState() => _WeeklySleepGardenState();
}

class _WeeklySleepGardenState extends State<WeeklySleepGarden>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate data for 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      // Find matching record
      final recordIndex = widget.records.indexWhere((r) =>
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day);
      final score = recordIndex != -1 ? widget.records[recordIndex].score : -1;
      return _GardenDayData(date: date, score: score);
    });

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Sleep Garden',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Icon(Icons.yard_outlined, color: Color(0xFF34D399), size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your habits grow plants. Reach 80+ for a blossom!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 24),
          // Garden display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < last7Days.length; i++)
                Expanded(
                  child: Column(
                    children: [
                      // Plant pot & drawing
                      SizedBox(
                        height: 90,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            final delay = i * 0.12;
                            final scale = (_controller.value - delay).clamp(0.0, 1.0);
                            return Transform.scale(
                              scale: Curves.elasticOut.transform(scale),
                              child: CustomPaint(
                                painter: _PlantPainter(
                                  score: last7Days[i].score,
                                  growthProgress: scale,
                                ),
                                size: const Size(40, 90),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Day label
                      Text(
                        _dayName(last7Days[i].date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Score label
                      Text(
                        last7Days[i].score != -1 ? '${last7Days[i].score}' : '-',
                        style: TextStyle(
                          color: last7Days[i].score != -1
                              ? _plantColor(last7Days[i].score)
                              : Colors.white24,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _dayName(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  Color _plantColor(int score) {
    if (score >= 80) return const Color(0xFFC084FC); // Flower purple
    if (score >= 50) return const Color(0xFF34D399); // Plant green
    return const Color(0xFFFBBF24); // Sprout gold/amber
  }
}

class _GardenDayData {
  _GardenDayData({required this.date, required this.score});

  final DateTime date;
  final int score;
}

class _PlantPainter extends CustomPainter {
  _PlantPainter({required this.score, required this.growthProgress});

  final int score;
  final double growthProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 18);

    // Draw Soil/Pot base
    final potPaint = Paint()
      ..color = const Color(0xFF475569) // Charcoal slate pot
      ..style = PaintingStyle.fill;
    final potPath = Path()
      ..moveTo(center.dx - 12, center.dy)
      ..lineTo(center.dx + 12, center.dy)
      ..lineTo(center.dx + 9, center.dy + 12)
      ..lineTo(center.dx - 9, center.dy + 12)
      ..close();
    canvas.drawPath(potPath, potPaint);

    // Draw pot rim
    final rimPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 28, height: 4),
        const Radius.circular(2),
      ),
      rimPaint,
    );

    if (score == -1) {
      // Empty pot, draw a dashed seedling outline (upcoming/no data)
      final dashPaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(center.translate(0, -10), 3, dashPaint);
      return;
    }

    if (growthProgress <= 0) return;

    final double plantHeight = (score >= 80 ? 46.0 : score >= 50 ? 36.0 : 22.0) * growthProgress;

    // Draw Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF34D399) // Mint green stem
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(center.dx, center.dy - 2)
      ..quadraticBezierTo(
        center.dx - 2 * math.sin(growthProgress * math.pi),
        center.dy - plantHeight / 2,
        center.dx,
        center.dy - plantHeight,
      );
    canvas.drawPath(stemPath, stemPaint);

    final leafPaint = Paint()
      ..color = const Color(0xFF059669) // Dark emerald green for leaves
      ..style = PaintingStyle.fill;

    if (score < 50) {
      // 🌱 Sprout: 2 tiny leaves at the top
      _drawLeaf(canvas, center.translate(0, -plantHeight), -math.pi / 4, leafPaint);
      _drawLeaf(canvas, center.translate(0, -plantHeight), math.pi / 4, leafPaint);
    } else if (score < 80) {
      // 🌿 Healthy Plant: multiple leaves along the stem
      _drawLeaf(canvas, center.translate(0, -plantHeight), -math.pi / 4, leafPaint);
      _drawLeaf(canvas, center.translate(0, -plantHeight), math.pi / 4, leafPaint);
      if (growthProgress > 0.5) {
        _drawLeaf(canvas, center.translate(-1, -plantHeight * 0.5), -math.pi / 2, leafPaint);
        _drawLeaf(canvas, center.translate(1, -plantHeight * 0.6), math.pi / 2, leafPaint);
      }
    } else {
      // 🌸 Flower: Healthy leaves + Beautiful flower blossom on top
      _drawLeaf(canvas, center.translate(0, -plantHeight * 0.4), -math.pi / 2, leafPaint);
      _drawLeaf(canvas, center.translate(0, -plantHeight * 0.6), math.pi / 2, leafPaint);

      // Draw blossom
      final flowerCenter = center.translate(0, -plantHeight);
      final petalPaint = Paint()
        ..color = const Color(0xFFF472B6) // Pink petals
        ..style = PaintingStyle.fill;

      // Draw 5 petals
      for (var i = 0; i < 5; i++) {
        final angle = i * 2 * math.pi / 5;
        final petalOffset = Offset(
          flowerCenter.dx + 5 * math.cos(angle) * growthProgress,
          flowerCenter.dy + 5 * math.sin(angle) * growthProgress,
        );
        canvas.drawCircle(petalOffset, 5 * growthProgress, petalPaint);
      }

      // Flower center
      final centerPaint = Paint()
        ..color = const Color(0xFFFEF08A) // Yellow core
        ..style = PaintingStyle.fill;
      canvas.drawCircle(flowerCenter, 3.5 * growthProgress, centerPaint);
    }
  }

  void _drawLeaf(Canvas canvas, Offset position, double rotation, Paint paint) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-4, -6, 0, -10)
      ..quadraticBezierTo(4, -6, 0, 0)
      ..close();
    canvas.drawPath(leaf, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PlantPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.growthProgress != growthProgress;
  }
}
