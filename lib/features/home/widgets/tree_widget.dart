import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../models/health_score.dart';
import 'leaf_particle.dart';

class TreeWidget extends StatefulWidget {
  const TreeWidget({super.key, required this.score});

  final HealthScore score;

  @override
  State<TreeWidget> createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget> with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _environmentController;
  late final AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: AppAnimations.xslow,
    )..repeat(reverse: true);
    _environmentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _environmentController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.score.treeLevel;
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _celebrationController.forward(from: 0),
        child: AspectRatio(
          aspectRatio: .84,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _environmentController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: EnvironmentPainter(
                        progress: _environmentController.value,
                        score: widget.score,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _environmentController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: WildlifePainter(
                        progress: _environmentController.value,
                        score: widget.score,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
                if (level.glows || widget.score.increased)
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, _) {
                      return Container(
                        width: 232 + _glowController.value * 44,
                        height: 232 + _glowController.value * 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.amber100.withValues(alpha: .16),
                          boxShadow: [
                            BoxShadow(
                              color: (level.blooms
                                      ? AppColors.pink200
                                      : AppColors.amber300)
                                  .withValues(alpha: .32),
                              blurRadius: 42 + _glowController.value * 28,
                              spreadRadius: 7,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                AnimatedBuilder(
                  animation: _environmentController,
                  builder: (context, child) {
                    final sway =
                        math.sin(_environmentController.value * math.pi * 2) *
                            (widget.score.isWilted ? .035 : .018);
                    final idleScale = 1 +
                        math.sin(_environmentController.value * math.pi * 2) *
                            .008;
                    return Transform.rotate(
                      angle:
                          widget.score.isWilted ? -math.pi / 30 + sway : sway,
                      child: Transform.scale(scale: idleScale, child: child),
                    );
                  },
                  child: AnimatedSwitcher(
                    duration: AppAnimations.slow,
                    switchInCurve: AppAnimations.curve,
                    switchOutCurve: AppAnimations.curve,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: .88, end: 1)
                              .animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: AnimatedOpacity(
                      key: ValueKey(level.level),
                      opacity: widget.score.isWilted ? .62 : 1,
                      duration: AppAnimations.normal,
                      child: Image.asset(
                        level.assetPath,
                        fit: BoxFit.contain,
                        width: 320,
                        height: 320,
                        errorBuilder: (context, error, stackTrace) {
                          return CustomPaint(
                            painter: FallbackTreePainter(
                              level: level.level,
                              wilted: widget.score.isWilted,
                              vitality: widget.score.total / 100,
                            ),
                            size: const Size(320, 320),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                LeafParticleLayer(
                  active: widget.score.decreased || widget.score.increased,
                  blossoms: widget.score.increased && level.blooms,
                ),
                AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: CelebrationPainter(
                        progress: _celebrationController.value,
                        blossoms: level.blooms,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
                Positioned(
                  left: 14,
                  bottom: 16,
                  child: _HabitRing(score: widget.score),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _Badge(level: level.level, score: widget.score.total),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: _TapHint(
                    onTap: () => _celebrationController.forward(from: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Tap the tree',
      child: Material(
        color: Colors.white.withValues(alpha: .70),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              Icons.touch_app_outlined,
              color: AppColors.green600,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class WildlifePainter extends CustomPainter {
  const WildlifePainter({required this.progress, required this.score});

  final double progress;
  final HealthScore score;

  @override
  void paint(Canvas canvas, Size size) {
    final birdPaint = Paint()
      ..color = AppColors.cyan700.withValues(alpha: .42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 2; i++) {
      final x = (size.width * (1.18 - i * .22) - progress * size.width * .82) %
          (size.width * 1.35);
      final y = size.height * (.17 + i * .08) +
          math.sin(progress * math.pi * 2 + i) * 8;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, y), width: 18, height: 9),
        math.pi,
        math.pi,
        false,
        birdPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x + 16, y), width: 18, height: 9),
        math.pi,
        math.pi,
        false,
        birdPaint,
      );
    }

    if (score.treeLevel.level >= 6) {
      final butterflyPaint = Paint()
        ..color = AppColors.pink400.withValues(alpha: .58);
      for (var i = 0; i < 3; i++) {
        final wing = 5 + math.sin(progress * math.pi * 4 + i) * 1.2;
        final x = size.width * (.24 + i * .22) +
            math.sin(progress * math.pi * 2 + i * 2) * 18;
        final y = size.height * (.43 + (i % 2) * .12) +
            math.cos(progress * math.pi * 2 + i) * 12;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x - 4, y), width: wing, height: 8),
          butterflyPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x + 4, y), width: wing, height: 8),
          butterflyPaint,
        );
      }
    }

    final flowerPaint = Paint()
      ..color =
          (score.treeLevel.blooms ? AppColors.pink200 : AppColors.amber100)
              .withValues(alpha: .68);
    final stemPaint = Paint()
      ..color = AppColors.green600.withValues(alpha: .42)
      ..strokeWidth = 1.2;
    for (var i = 0; i < score.treeLevel.level.clamp(2, 10); i++) {
      final x = size.width * (.15 + i * .075);
      final y = size.height * (.84 + (i % 3) * .025);
      canvas.drawLine(Offset(x, y + 4), Offset(x, y + 11), stemPaint);
      canvas.drawCircle(Offset(x, y), 3.8, flowerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WildlifePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.score != score;
  }
}

class CelebrationPainter extends CustomPainter {
  const CelebrationPainter({required this.progress, required this.blossoms});

  final double progress;
  final bool blossoms;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final opacity = (1 - progress).clamp(0.0, 1.0);
    final sparkle = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final petal = Paint()
      ..color = (blossoms ? AppColors.pink200 : AppColors.green400)
          .withValues(alpha: opacity);
    for (var i = 0; i < 24; i++) {
      final angle = i * math.pi * 2 / 24;
      final radius = 34 + progress * (118 + (i % 4) * 12);
      final center = Offset(
        size.width / 2 + math.cos(angle) * radius,
        size.height * .48 + math.sin(angle) * radius * .72,
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + progress * math.pi);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: blossoms ? 8 : 10,
          height: blossoms ? 8 : 15,
        ),
        petal,
      );
      canvas.restore();
      if (i % 3 == 0) {
        canvas.drawLine(
            center.translate(-4, 0), center.translate(4, 0), sparkle);
        canvas.drawLine(
            center.translate(0, -4), center.translate(0, 4), sparkle);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.blossoms != blossoms;
  }
}

class _HabitRing extends StatelessWidget {
  const _HabitRing({required this.score});

  final HealthScore score;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(AppDimens.pill),
        border: Border.all(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                value: score.total / 100,
                strokeWidth: 4,
                color: AppColors.green400,
                backgroundColor: AppColors.cyan100,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Garden sync',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.level, required this.score});

  final int level;
  final int score;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(AppDimens.pill),
        border: Border.all(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'Lv.$level  $score',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class EnvironmentPainter extends CustomPainter {
  const EnvironmentPainter({required this.progress, required this.score});

  final double progress;
  final HealthScore score;

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final night = now.hour >= 18 || now.hour < 6;
    final season = (now.month - 1) ~/ 3;
    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: night
            ? [const Color(0xFF123047), const Color(0xFFBFE9F3)]
            : score.isWilted
                ? [const Color(0xFFE8EEF4), AppColors.cyan50]
                : score.total >= 75
                    ? [const Color(0xFFFFF7D6), AppColors.cyan50]
                    : [AppColors.cyan50, const Color(0xFFEFFDF1)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final rayPaint = Paint()
      ..color = (night ? Colors.white : AppColors.amber100)
          .withValues(alpha: night ? .12 : .20)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final x = size.width * (.12 + i * .20) +
          math.sin(progress * math.pi * 2 + i) * 8;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.width * .14, size.height * .58),
        rayPaint,
      );
    }

    final hillPaint = Paint()
      ..color = (season == 3 ? AppColors.cyan100 : AppColors.green100)
          .withValues(alpha: night ? .34 : .42);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .50, size.height * .94),
        width: size.width * 1.22,
        height: size.height * .28,
      ),
      hillPaint,
    );

    if (night) {
      final moonPaint = Paint()..color = Colors.white.withValues(alpha: .78);
      canvas.drawCircle(
        Offset(size.width * .22, size.height * .16),
        24 + math.sin(progress * math.pi * 2) * 2,
        moonPaint,
      );
      final starPaint = Paint()..color = Colors.white.withValues(alpha: .62);
      for (var i = 0; i < 14; i++) {
        final seed = i * 17.0;
        final twinkle = .35 + (math.sin(progress * math.pi * 2 + i) + 1) * .22;
        starPaint.color = Colors.white.withValues(alpha: twinkle);
        canvas.drawCircle(
          Offset(
            size.width * ((math.sin(seed) + 1) / 2),
            size.height * (.08 + ((math.cos(seed) + 1) / 2) * .28),
          ),
          1.4 + (i % 3) * .45,
          starPaint,
        );
      }
    } else if (score.total >= 75) {
      final sunPaint = Paint()
        ..color = AppColors.amber100.withValues(alpha: .72);
      canvas.drawCircle(
        Offset(size.width * .20, size.height * .18),
        28 + math.sin(progress * math.pi * 2) * 3,
        sunPaint,
      );
    }

    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: night ? .34 : .76);
    for (var i = 0; i < 3; i++) {
      final x = (size.width * (.22 + i * .30) + progress * 38) % size.width;
      final y = size.height * (.18 + (i % 2) * .10);
      canvas.drawCircle(Offset(x, y), 18, cloudPaint);
      canvas.drawCircle(Offset(x + 18, y + 4), 14, cloudPaint);
      canvas.drawCircle(Offset(x - 18, y + 6), 12, cloudPaint);
    }

    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 22; i++) {
      final seed = i * 31.0;
      final x = (size.width * ((math.sin(seed) + 1) / 2) +
              math.sin(progress * math.pi * 2 + i) * 18) %
          size.width;
      final y = (size.height * ((math.cos(seed) + 1) / 2) -
              progress * size.height * .22) %
          size.height;
      particlePaint.color = _seasonParticleColor(season, night)
          .withValues(alpha: night ? .32 : .24);
      canvas.drawCircle(Offset(x, y), 1.6 + (i % 4) * .35, particlePaint);
    }

    final leafPaint = Paint()
      ..color = (season == 2 ? AppColors.amber300 : AppColors.green400)
          .withValues(alpha: .30);
    for (var i = 0; i < 9; i++) {
      final seed = i * 23.0;
      final x = (size.width * ((math.sin(seed) + 1) / 2) +
              progress * size.width * .18) %
          size.width;
      final y = (size.height * (.18 + ((math.cos(seed) + 1) / 2) * .54) +
              progress * size.height * .28) %
          size.height;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 2 + i);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 8, height: 14),
        leafPaint,
      );
      canvas.restore();
    }

    final rainPaint = Paint()
      ..color = (score.isWilted ? AppColors.cyan700 : AppColors.cyan600)
          .withValues(alpha: score.total >= 75 ? .10 : .30)
      ..strokeWidth = score.isWilted ? 1.8 : 1.2
      ..strokeCap = StrokeCap.round;
    final drops = score.total >= 75 ? 10 : 26;
    for (var i = 0; i < drops; i++) {
      final seed = i * 19.0;
      final x = (size.width * ((math.sin(seed) + 1) / 2) + progress * 42) %
          size.width;
      final y =
          (size.height * ((math.cos(seed) + 1) / 2) + progress * size.height) %
              size.height;
      canvas.drawLine(Offset(x, y), Offset(x - 4, y + 11), rainPaint);
    }
  }

  Color _seasonParticleColor(int season, bool night) {
    if (night) {
      return Colors.white;
    }
    switch (season) {
      case 0:
        return AppColors.pink200;
      case 1:
        return AppColors.amber100;
      case 2:
        return AppColors.amber300;
      default:
        return AppColors.cyan100;
    }
  }

  @override
  bool shouldRepaint(covariant EnvironmentPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.score != score;
  }
}

class FallbackTreePainter extends CustomPainter {
  const FallbackTreePainter({
    required this.level,
    required this.wilted,
    required this.vitality,
  });

  final int level;
  final bool wilted;
  final double vitality;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .58);
    final trunkPaint = Paint()
      ..color =
          wilted ? AppColors.trunk.withValues(alpha: .65) : AppColors.trunk;
    final leafPaint = Paint()
      ..color = wilted
          ? AppColors.green100
          : Color.lerp(AppColors.green100, AppColors.green400, vitality)!;
    final shadowPaint = Paint()
      ..color = AppColors.green600.withValues(alpha: .18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final blossomPaint = Paint()..color = AppColors.pink200;
    final soilPaint = Paint()
      ..color = AppColors.trunkDark.withValues(alpha: .22);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * .88),
        width: size.width * .62,
        height: 22,
      ),
      soilPaint,
    );

    if (level == 1) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * .78),
          width: 54,
          height: 34,
        ),
        trunkPaint,
      );
      canvas.drawCircle(
        Offset(size.width / 2, size.height * .70),
        10,
        leafPaint,
      );
      return;
    }

    final heightFactor = (.34 + level * .045).clamp(.38, .72);
    final trunk = Path()
      ..moveTo(center.dx - 15, size.height * .84)
      ..quadraticBezierTo(center.dx - 8, size.height * .62, center.dx - 4,
          size.height * (1 - heightFactor))
      ..lineTo(center.dx + 14, size.height * (1 - heightFactor))
      ..quadraticBezierTo(
          center.dx + 11, size.height * .62, center.dx + 19, size.height * .84)
      ..close();
    canvas.drawPath(trunk, trunkPaint);

    final branchPaint = Paint()
      ..color = AppColors.trunkDark.withValues(alpha: wilted ? .36 : .58)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final branchY = size.height * (1 - heightFactor + .06);
    canvas.drawLine(
      Offset(center.dx + 2, branchY),
      Offset(center.dx - 52, branchY + 22),
      branchPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 6, branchY + 4),
      Offset(center.dx + 56, branchY + 20),
      branchPaint,
    );

    final canopyRadius = 34.0 + level * 10;
    final canopyY = size.height * (1 - heightFactor);
    canvas.drawCircle(
      Offset(center.dx, canopyY + 8),
      canopyRadius * .92,
      shadowPaint,
    );
    for (final offset in [
      const Offset(0, 0),
      Offset(-canopyRadius * .55, canopyRadius * .16),
      Offset(canopyRadius * .55, canopyRadius * .12),
      Offset(0, -canopyRadius * .34),
      Offset(-canopyRadius * .10, canopyRadius * .34),
    ]) {
      canvas.drawCircle(
        Offset(center.dx + offset.dx, canopyY + offset.dy),
        canopyRadius * .62,
        leafPaint,
      );
    }

    final sparklePaint = Paint()..color = Colors.white.withValues(alpha: .76);
    for (var i = 0; i < math.max(3, level); i++) {
      final angle = i * math.pi * .7;
      final radius = canopyRadius * (.30 + (i % 3) * .15);
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * radius,
          canopyY + math.sin(angle) * radius * .72,
        ),
        2.4,
        sparklePaint,
      );
    }

    if (level >= 6) {
      for (var i = 0; i < level + 4; i++) {
        final angle = i * math.pi * .62;
        final radius = canopyRadius * (.28 + (i % 4) * .14);
        canvas.drawCircle(
          Offset(
            center.dx + math.cos(angle) * radius,
            canopyY + math.sin(angle) * radius * .72,
          ),
          5 + (i % 3),
          blossomPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FallbackTreePainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.wilted != wilted ||
        oldDelegate.vitality != vitality;
  }
}
