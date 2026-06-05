import 'dart:math' as math;
import 'package:flutter/material.dart';

class SleepHeroSection extends StatefulWidget {
  const SleepHeroSection({
    super.key,
    required this.sleepGoalHours,
    required this.bedtime,
    required this.wakeUpTime,
  });

  final double sleepGoalHours;
  final TimeOfDay bedtime;
  final TimeOfDay wakeUpTime;

  @override
  State<SleepHeroSection> createState() => _SleepHeroSectionState();
}

class _SleepHeroSectionState extends State<SleepHeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
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
      height: 280,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0F172A).withValues(alpha: 0.8), // Deep slate blue
            const Color(0xFF1E293B).withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // Animated Sky Painter
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SkyPainter(progress: _controller.value),
                  );
                },
              ),
            ),
          ),
          // Content overlay
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🌙',
                          style: TextStyle(fontSize: 26),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Good Evening',
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Let\'s wind down for a restful night.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                // Stats Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatPill(
                      label: 'Sleep Goal',
                      value: '${widget.sleepGoalHours.toStringAsFixed(0)} hrs',
                      icon: Icons.track_changes,
                    ),
                    _StatPill(
                      label: 'Bedtime',
                      value: _formatTime(widget.bedtime),
                      icon: Icons.nights_stay_outlined,
                    ),
                    _StatPill(
                      label: 'Wake Up',
                      value: _formatTime(widget.wakeUpTime),
                      icon: Icons.wb_sunny_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFFC084FC)), // Soft purple accent
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Moonlight Glow
    final moonCenter = Offset(size.width * 0.78, size.height * 0.35);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFEF08A).withValues(alpha: 0.22 + 0.05 * math.sin(progress * 2 * math.pi)),
          const Color(0xFFFEF08A).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: 110));
    canvas.drawCircle(moonCenter, 110, glowPaint);

    // 2. Draw Moon Glow (closer ring)
    final moonGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFEF08A).withValues(alpha: 0.6),
          const Color(0xFFFEF08A).withValues(alpha: 0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: 45));
    canvas.drawCircle(moonCenter, 45, moonGlowPaint);

    // 3. Draw Moon Body
    final moonPaint = Paint()..color = Colors.white;
    canvas.drawCircle(moonCenter, 28, moonPaint);

    // Moonlight Crater Shadow Detail (subtle inner glow/shadow)
    final shadowPaint = Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.3);
    canvas.drawCircle(moonCenter.translate(-5, -3), 20, shadowPaint);

    // 4. Draw Stars
    final starPaint = Paint()..color = Colors.white;
    // We seed 12 stars with fixed coordinates but animated twinkle
    final random = math.Random(42);
    for (var i = 0; i < 12; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.7; // Keep stars in top 70%

      // Twinkle calculation
      final speed = 0.5 + random.nextDouble() * 1.5;
      final phase = random.nextDouble() * 2 * math.pi;
      final twinkle = 0.2 + 0.8 * (0.5 + 0.5 * math.sin(progress * 2 * math.pi * speed + phase));

      starPaint.color = Colors.white.withValues(alpha: twinkle);
      final sizeFactor = 1.0 + random.nextDouble() * 1.5;

      canvas.drawCircle(Offset(x, y), sizeFactor, starPaint);
    }

    // 5. Draw Moving Clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (var i = 0; i < 2; i++) {
      // Horizontal slide
      final cloudProgress = (progress + (i * 0.5)) % 1.0;
      final x = size.width * 1.2 * cloudProgress - (size.width * 0.2);
      final y = size.height * (0.2 + i * 0.15);

      canvas.drawCircle(Offset(x, y), 25, cloudPaint);
      canvas.drawCircle(Offset(x - 15, y + 5), 18, cloudPaint);
      canvas.drawCircle(Offset(x + 15, y + 5), 18, cloudPaint);
      canvas.drawCircle(Offset(x - 30, y + 10), 12, cloudPaint);
      canvas.drawCircle(Offset(x + 30, y + 10), 12, cloudPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
