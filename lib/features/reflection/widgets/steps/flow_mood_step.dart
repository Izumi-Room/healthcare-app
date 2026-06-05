import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlowMoodStep extends StatefulWidget {
  const FlowMoodStep({super.key, required this.onSelected, this.selected});

  final ValueChanged<String> onSelected;
  final String? selected;

  @override
  State<FlowMoodStep> createState() => _FlowMoodStepState();
}

class _FlowMoodStepState extends State<FlowMoodStep> {
  static const _moods = [
    _MoodOption('😁', 'Luar Biasa', Color(0xFF4CAF50)),
    _MoodOption('😊', 'Senang', Color(0xFF66BB6A)),
    _MoodOption('😌', 'Damai', Color(0xFF42A5F5)),
    _MoodOption('😐', 'Biasa', Color(0xFFFFCA28)),
    _MoodOption('😔', 'Sedih', Color(0xFF7E57C2)),
    _MoodOption('😫', 'Lelah', Color(0xFFEF5350)),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Pilih mood-mu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bagaimana perasaanmu saat ini?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.35,
            ),
            itemCount: _moods.length,
            itemBuilder: (context, index) {
              final mood = _moods[index];
              final isSelected = widget.selected == mood.label;
              return _MoodCard(
                mood: mood,
                isSelected: isSelected,
                delay: index * 80,
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onSelected(mood.label);
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption(this.emoji, this.label, this.color);
  final String emoji;
  final String label;
  final Color color;
}

class _MoodCard extends StatefulWidget {
  const _MoodCard({
    required this.mood,
    required this.isSelected,
    required this.delay,
    required this.onTap,
  });

  final _MoodOption mood;
  final bool isSelected;
  final int delay;
  final VoidCallback onTap;

  @override
  State<_MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<_MoodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _enterScale;
  late Animation<double> _enterFade;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _enterScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.elasticOut),
    );
    _enterFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _enterController.forward();
    });
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _enterFade,
      child: ScaleTransition(
        scale: _enterScale,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.mood.color.withValues(alpha: .12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isSelected
                    ? widget.mood.color
                    : Colors.grey[300]!,
                width: widget.isSelected ? 3 : 1.5,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: widget.mood.color.withValues(alpha: .25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: widget.isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  child: Text(
                    widget.mood.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: widget.isSelected ? 15 : 14,
                    fontWeight:
                        widget.isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: widget.isSelected
                        ? widget.mood.color
                        : Colors.grey[700],
                  ),
                  child: Text(widget.mood.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
