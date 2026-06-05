import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlowEmotionStep extends StatefulWidget {
  const FlowEmotionStep({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  State<FlowEmotionStep> createState() => _FlowEmotionStepState();
}

class _FlowEmotionStepState extends State<FlowEmotionStep> {
  static const _emotions = [
    _Emotion('🙏', 'Bersyukur'),
    _Emotion('💪', 'Termotivasi'),
    _Emotion('⚡', 'Produktif'),
    _Emotion('🎉', 'Excited'),
    _Emotion('😎', 'Percaya Diri'),
    _Emotion('🧘', 'Rileks'),
    _Emotion('😰', 'Cemas'),
    _Emotion('😤', 'Kewalahan'),
    _Emotion('💔', 'Kesepian'),
    _Emotion('😤', 'Frustrasi'),
  ];

  void _toggle(String emotion) {
    HapticFeedback.selectionClick();
    final updated = List<String>.from(widget.selected);
    if (updated.contains(emotion)) {
      updated.remove(emotion);
    } else {
      updated.add(emotion);
    }
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Apa yang kamu rasakan?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Pilih semua yang sesuai',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(_emotions.length, (index) {
                final emotion = _emotions[index];
                final isSelected = widget.selected.contains(emotion.label);
                return _EmotionChip(
                  emotion: emotion,
                  isSelected: isSelected,
                  delay: index * 60,
                  onTap: () => _toggle(emotion.label),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Emotion {
  const _Emotion(this.emoji, this.label);
  final String emoji;
  final String label;
}

class _EmotionChip extends StatefulWidget {
  const _EmotionChip({
    required this.emotion,
    required this.isSelected,
    required this.delay,
    required this.onTap,
  });

  final _Emotion emotion;
  final bool isSelected;
  final int delay;
  final VoidCallback onTap;

  @override
  State<_EmotionChip> createState() => _EmotionChipState();
}

class _EmotionChipState extends State<_EmotionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFF4CAF50).withValues(alpha: .1)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF4CAF50)
                  : Colors.grey[300]!,
              width: widget.isSelected ? 2.5 : 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: .2),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emotion.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                widget.emotion.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey[700],
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Color(0xFF4CAF50),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
