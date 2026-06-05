import 'package:flutter/material.dart';

class FlowGratitudeStep extends StatefulWidget {
  const FlowGratitudeStep({
    super.key,
    required this.controllers,
  });

  final List<TextEditingController> controllers;

  @override
  State<FlowGratitudeStep> createState() => _FlowGratitudeStepState();
}

class _FlowGratitudeStepState extends State<FlowGratitudeStep> {
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
              'Rasa Syukur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Sebutkan 3 hal yang kamu syukuri hari ini',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          for (var i = 0; i < 3; i++) ...[
            _GratitudeCard(
              index: i,
              controller: widget.controllers[i],
              delay: i * 150,
            ),
            if (i < 2) const SizedBox(height: 14),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _GratitudeCard extends StatefulWidget {
  const _GratitudeCard({
    required this.index,
    required this.controller,
    required this.delay,
  });

  final int index;
  final TextEditingController controller;
  final int delay;

  @override
  State<_GratitudeCard> createState() => _GratitudeCardState();
}

class _GratitudeCardState extends State<_GratitudeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _hasFocus = false;

  static const _emojis = ['🌟', '💛', '✨'];
  static const _hints = [
    'Hal pertama yang kamu syukuri...',
    'Hal kedua yang kamu syukuri...',
    'Hal ketiga yang kamu syukuri...',
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _animController.forward();
    });
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Focus(
          onFocusChange: (focused) => setState(() => _hasFocus = focused),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _hasFocus
                  ? const Color(0xFFFFF8E1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hasFocus
                    ? const Color(0xFFFFB300)
                    : Colors.grey[300]!,
                width: _hasFocus ? 2 : 1.5,
              ),
              boxShadow: _hasFocus
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFB300).withValues(alpha: .15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Number/emoji badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: .3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _emojis[widget.index],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: _hints[widget.index],
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      _onTextChanged();
                    },
                    child: Icon(
                      Icons.clear_rounded,
                      size: 18,
                      color: Colors.grey[400],
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
