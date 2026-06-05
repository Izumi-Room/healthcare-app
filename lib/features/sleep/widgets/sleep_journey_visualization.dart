import 'dart:math' as math;
import 'package:flutter/material.dart';

class SleepJourneyVisualization extends StatefulWidget {
  const SleepJourneyVisualization({super.key});

  @override
  State<SleepJourneyVisualization> createState() => _SleepJourneyVisualizationState();
}

class _SleepJourneyVisualizationState extends State<SleepJourneyVisualization>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final int _hoveredIndex = -1;

  // Mock sleep cycle segments: [Stage, duration in minutes]
  // 0: Awake, 1: REM, 2: Light, 3: Deep
  final List<Map<String, dynamic>> _segments = [
    {'stage': 0, 'duration': 15, 'time': '22:00'},
    {'stage': 2, 'duration': 45, 'time': '22:15'},
    {'stage': 3, 'duration': 60, 'time': '23:00'},
    {'stage': 2, 'duration': 90, 'time': '00:00'},
    {'stage': 1, 'duration': 30, 'time': '01:30'},
    {'stage': 3, 'duration': 45, 'time': '02:00'},
    {'stage': 2, 'duration': 90, 'time': '02:45'},
    {'stage': 1, 'duration': 40, 'time': '04:15'},
    {'stage': 2, 'duration': 50, 'time': '04:55'},
    {'stage': 0, 'duration': 15, 'time': '05:45'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B).withValues(alpha: 0.8),
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
                'Sleep Journey',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.waves, color: Color(0xFFC084FC), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your sleep cycles through last night.',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),

          // Hypnogram Chart
          SizedBox(
            height: 140,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _HypnogramPainter(
                    segments: _segments,
                    animationProgress: _controller.value,
                    hoveredIndex: _hoveredIndex,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Time scale
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('22:00', style: TextStyle(color: Colors.white30, fontSize: 10)),
              Text('00:00', style: TextStyle(color: Colors.white30, fontSize: 10)),
              Text('02:00', style: TextStyle(color: Colors.white30, fontSize: 10)),
              Text('04:00', style: TextStyle(color: Colors.white30, fontSize: 10)),
              Text('06:00', style: TextStyle(color: Colors.white30, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),

          // Color Legend
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendItem(color: Color(0xFFFDE047), label: 'Awake'),
              _LegendItem(color: Color(0xFFC084FC), label: 'REM'),
              _LegendItem(color: Color(0xFF60A5FA), label: 'Light'),
              _LegendItem(color: Color(0xFF3B82F6), label: 'Deep'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HypnogramPainter extends CustomPainter {
  _HypnogramPainter({
    required this.segments,
    required this.animationProgress,
    required this.hoveredIndex,
  });

  final List<Map<String, dynamic>> segments;
  final double animationProgress;
  final int hoveredIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final totalDuration = segments.fold<int>(0, (sum, s) => sum + (s['duration'] as int));
    if (totalDuration == 0) return;

    final widthPerMinute = size.width / totalDuration;
    final double maxDrawWidth = size.width * animationProgress;

    // Height levels mapping
    // Awake = top (level 0), REM = level 1, Light = level 2, Deep = bottom (level 3)
    final double levelHeightStep = size.height / 4;
    double getLevelY(int stage) {
      // 0 -> top (margin), 3 -> bottom (margin)
      return 15 + stage * levelHeightStep;
    }

    final path = Path();
    final fillPath = Path();

    double currentX = 0;
    bool pathStarted = false;

    for (var i = 0; i < segments.length; i++) {
      final stage = segments[i]['stage'] as int;
      final duration = segments[i]['duration'] as int;
      final segmentWidth = duration * widthPerMinute;
      final stageY = getLevelY(stage);

      if (currentX > maxDrawWidth) break;

      final double endX = math.min(currentX + segmentWidth, maxDrawWidth);

      if (!pathStarted) {
        path.moveTo(currentX, stageY);
        fillPath.moveTo(currentX, size.height);
        fillPath.lineTo(currentX, stageY);
        pathStarted = true;
      }

      // Horizontal line across stage duration
      path.lineTo(endX, stageY);
      fillPath.lineTo(endX, stageY);

      // If we haven't reached full width, add vertical transition to next stage
      if (endX < maxDrawWidth && i < segments.length - 1) {
        final nextStage = segments[i + 1]['stage'] as int;
        final nextY = getLevelY(nextStage);
        path.lineTo(endX, nextY);
        fillPath.lineTo(endX, nextY);
      }

      currentX = endX;
    }

    // Close fill path
    fillPath.lineTo(currentX, size.height);
    fillPath.close();

    // Paint for background fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFC084FC).withValues(alpha: 0.15),
          const Color(0xFF8B5CF6).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fillPaint);

    // Paint for hypnogram line
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFDE047), // Awake color
          Color(0xFFC084FC), // REM color
          Color(0xFF60A5FA), // Light sleep
          Color(0xFF3B82F6), // Deep sleep
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw indicators or circles at nodes
    currentX = 0;
    final dotPaint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < segments.length; i++) {
      final stage = segments[i]['stage'] as int;
      final duration = segments[i]['duration'] as int;
      final segmentWidth = duration * widthPerMinute;
      final stageY = getLevelY(stage);

      if (currentX > maxDrawWidth) break;

      Color stageColor;
      switch (stage) {
        case 0:
          stageColor = const Color(0xFFFDE047);
          break;
        case 1:
          stageColor = const Color(0xFFC084FC);
          break;
        case 2:
          stageColor = const Color(0xFF60A5FA);
          break;
        default:
          stageColor = const Color(0xFF3B82F6);
      }

      // Draw start dot
      dotPaint.color = stageColor;
      canvas.drawCircle(Offset(currentX, stageY), 4, dotPaint);

      currentX += segmentWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _HypnogramPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}
