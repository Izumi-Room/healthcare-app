import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../shared/widgets/mascot_helper.dart';

class FlowCompletionStep extends StatefulWidget {
  const FlowCompletionStep({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<FlowCompletionStep> createState() => _FlowCompletionStepState();
}

class _FlowCompletionStepState extends State<FlowCompletionStep>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _xpController;
  late Animation<double> _xpValue;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _xpValue = Tween<double>(begin: 0, end: 100).animate(
      CurvedAnimation(parent: _xpController, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _xpController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) => CustomPaint(
                painter: _CelebrationPainter(_confettiController.value),
              ),
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Success icon
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _scaleController,
                  curve: Curves.elasticOut,
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: .3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: MascotAvatar(mood: MascotMood.excited, size: 84),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Luar Biasa!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kamu telah menyelesaikan refleksi hari ini.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 15,
                    ),
              ),
              const SizedBox(height: 32),
              // XP reward badge
              AnimatedBuilder(
                animation: _xpValue,
                builder: (context, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withValues(alpha: .35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Text(
                          '+${_xpValue.value.round()} XP',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF9C27B0).withValues(alpha: .2),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      'Streak refleksi bertambah!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7B1FA2),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              // Finish button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: widget.onFinish,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Kembali ke Jurnal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFFFFB300),
      const Color(0xFFE91E63),
      const Color(0xFF42A5F5),
      const Color(0xFF7E57C2),
      const Color(0xFFFF7043),
    ];
    final paint = Paint();
    for (var i = 0; i < 40; i++) {
      final x = size.width * ((math.sin(i * 7.3) + 1) / 2);
      final y = size.height * progress * 1.2 +
          math.cos(i * 3.7) * 50 -
          100;
      paint.color = colors[i % colors.length]
          .withValues(alpha: (1 - progress * 0.7).clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 3 + i * 0.5);
      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, 3 + (i % 4), paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-4, -2.5, 8, 5),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter old) =>
      old.progress != progress;
}
