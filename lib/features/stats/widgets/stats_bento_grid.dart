import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/providers/health_score_provider.dart';
import '../providers/stats_provider.dart';

class StatsBentoGrid extends ConsumerWidget {
  const StatsBentoGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(healthScoreProvider);
    final learningMins = ref.watch(learningTimeProvider);
    final streak = score.goodStreakDays.clamp(0, 30);
    final totalXp = score.total * 30;

    // Convert minutes to hours+min string
    final hrs = learningMins ~/ 60;
    final mins = learningMins % 60;
    final timeLabel = hrs > 0 ? '${hrs}j ${mins}m' : '${mins}m';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Cepat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Row 1: Two wide cards
        Row(
          children: [
            Expanded(
              child: _BentoTile(
                emoji: '⏱️',
                label: 'Waktu Belajar',
                value: timeLabel,
                color: const Color(0xFF6366F1), // Indigo
                delay: 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoTile(
                emoji: '🔥',
                label: 'Hari Streak',
                value: '$streak',
                color: const Color(0xFFF97316), // Orange
                delay: 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: Three narrower cards
        Row(
          children: [
            Expanded(
              child: _BentoTile(
                emoji: '⚡',
                label: 'Total XP',
                value: totalXp > 999 ? '${(totalXp / 1000).toStringAsFixed(1)}k' : '$totalXp',
                color: const Color(0xFFEAB308), // Yellow
                delay: 200,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoTile(
                emoji: '🌙',
                label: 'Tidur',
                value: '${score.sleep}/25',
                color: const Color(0xFF8B5CF6), // Purple
                delay: 300,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoTile(
                emoji: '😊',
                label: 'Mood',
                value: '${score.mood}/25',
                color: const Color(0xFF06B6D4), // Cyan
                delay: 400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BentoTile extends StatefulWidget {
  const _BentoTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;
  final int delay;

  @override
  State<_BentoTile> createState() => _BentoTileState();
}

class _BentoTileState extends State<_BentoTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.color.withValues(alpha: .25),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.color.withValues(alpha: .7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
