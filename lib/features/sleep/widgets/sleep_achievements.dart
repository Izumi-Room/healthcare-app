import 'dart:math' as math;
import 'package:flutter/material.dart';

class SleepAchievements extends StatefulWidget {
  const SleepAchievements({super.key});

  @override
  State<SleepAchievements> createState() => _SleepAchievementsState();
}

class _SleepAchievementsState extends State<SleepAchievements>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebrationController;
  int _celebratingIndex = -1;
  Offset _tapPosition = Offset.zero;

  final List<_AchievementItem> _items = const [
    _AchievementItem('Early Sleeper', '🌙', 'Slept before 22:30', true, Color(0xFFFEF08A)),
    _AchievementItem('7 Nights Goal', '⭐', 'Logged sleep 7 days in a row', true, Color(0xFF60A5FA)),
    _AchievementItem('Deep Sleep Master', '💤', 'Achieved > 2 hours deep sleep', true, Color(0xFFC084FC)),
    _AchievementItem('Sleep Champion', '🏆', 'Completed all monthly goals', false, Color(0xFFFCA5A5)),
  ];

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _triggerCelebration(int index, TapUpDetails details, BuildContext context) {
    if (!_items[index].unlocked) return; // Only celebrate unlocked ones

    final box = context.findRenderObject() as RenderBox;
    final localOffset = box.globalToLocal(details.globalPosition);

    setState(() {
      _celebratingIndex = index;
      _tapPosition = localOffset;
    });

    _celebrationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Milestones you have achieved as a sleep companion.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 16),

            // Bento Grid of Achievements
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onTapUp: (details) => _triggerCelebration(index, details, context),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF0F172A),
                      border: Border.all(
                        color: item.unlocked
                            ? item.accentColor.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.05),
                        width: item.unlocked ? 1.5 : 1,
                      ),
                      boxShadow: item.unlocked
                          ? [
                              BoxShadow(
                                color: item.accentColor.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Opacity(
                      opacity: item.unlocked ? 1.0 : 0.45,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: item.accentColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
                              ),
                              if (!item.unlocked)
                                const Icon(Icons.lock_outline, color: Colors.white38, size: 16),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        // Floating sparkles animation layer
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _celebrationController,
              builder: (context, _) {
                if (!_celebrationController.isAnimating || _celebratingIndex == -1) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: _SparklePainter(
                    center: _tapPosition,
                    progress: _celebrationController.value,
                    color: _items[_celebratingIndex].accentColor,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementItem {
  const _AchievementItem(
    this.title,
    this.emoji,
    this.description,
    this.unlocked,
    this.accentColor,
  );

  final String title;
  final String emoji;
  final String description;
  final bool unlocked;
  final Color accentColor;
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({
    required this.center,
    required this.progress,
    required this.color,
  });

  final Offset center;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final sparkPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final random = math.Random(10);
    const particleCount = 14;

    for (var i = 0; i < particleCount; i++) {
      final angle = i * 2 * math.pi / particleCount + (random.nextDouble() * 0.2);
      final speed = 25.0 + random.nextDouble() * 35.0;
      final distance = speed * progress;

      final sparkPosition = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle),
      );

      final sparkRadius = (4.0 * (1.0 - progress)).clamp(0.5, 4.0);

      // Render a mix of circles and small diamonds/crosses
      if (i % 2 == 0) {
        canvas.drawCircle(sparkPosition, sparkRadius, sparkPaint);
      } else {
        final path = Path()
          ..moveTo(sparkPosition.dx, sparkPosition.dy - sparkRadius * 1.5)
          ..lineTo(sparkPosition.dx + sparkRadius * 1.5, sparkPosition.dy)
          ..lineTo(sparkPosition.dx, sparkPosition.dy + sparkRadius * 1.5)
          ..lineTo(sparkPosition.dx - sparkRadius * 1.5, sparkPosition.dy)
          ..close();
        canvas.drawPath(path, sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.center != center;
  }
}
