import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlowHighlightStep extends StatefulWidget {
  const FlowHighlightStep({
    super.key,
    required this.onSelected,
    this.selected,
  });

  final ValueChanged<String> onSelected;
  final String? selected;

  @override
  State<FlowHighlightStep> createState() => _FlowHighlightStepState();
}

class _FlowHighlightStepState extends State<FlowHighlightStep> {
  static const _highlights = [
    _Highlight('🌟', 'Pencapaian', Color(0xFFFFB300)),
    _Highlight('❤️', 'Keluarga', Color(0xFFE91E63)),
    _Highlight('👥', 'Teman', Color(0xFF42A5F5)),
    _Highlight('📚', 'Belajar', Color(0xFF7E57C2)),
    _Highlight('💼', 'Kerja', Color(0xFF26A69A)),
    _Highlight('🎮', 'Hiburan', Color(0xFFFF7043)),
    _Highlight('🌙', 'Istirahat', Color(0xFF5C6BC0)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Highlight hari ini',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Apa yang paling berkesan?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.separated(
              itemCount: _highlights.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final highlight = _highlights[index];
                final isSelected = widget.selected == highlight.label;
                return _HighlightCard(
                  highlight: highlight,
                  isSelected: isSelected,
                  delay: index * 70,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onSelected(highlight.label);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Highlight {
  const _Highlight(this.emoji, this.label, this.color);
  final String emoji;
  final String label;
  final Color color;
}

class _HighlightCard extends StatefulWidget {
  const _HighlightCard({
    required this.highlight,
    required this.isSelected,
    required this.delay,
    required this.onTap,
  });

  final _Highlight highlight;
  final bool isSelected;
  final int delay;
  final VoidCallback onTap;

  @override
  State<_HighlightCard> createState() => _HighlightCardState();
}

class _HighlightCardState extends State<_HighlightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: widget.isSelected ? 20 : 16,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.highlight.color.withValues(alpha: .08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isSelected
                    ? widget.highlight.color
                    : Colors.grey[300]!,
                width: widget.isSelected ? 2.5 : 1.5,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: widget.highlight.color.withValues(alpha: .2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedScale(
                  scale: widget.isSelected ? 1.3 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    widget.highlight.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.highlight.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: widget.isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: widget.isSelected
                          ? widget.highlight.color
                          : Colors.grey[700],
                    ),
                  ),
                ),
                if (widget.isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: widget.highlight.color,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
