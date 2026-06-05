import 'package:flutter/material.dart';

/// Available mascot expressions mapped to asset files.
enum MascotMood {
  excited('assets/mascot/excited.png'),
  wink('assets/mascot/wink.png'),
  think('assets/mascot/think.png'),
  loading('assets/mascot/loading.png');

  const MascotMood(this.assetPath);

  final String assetPath;
}

/// A floating mascot image with a gentle hover animation.
class MascotAvatar extends StatefulWidget {
  const MascotAvatar({
    super.key,
    this.mood = MascotMood.wink,
    this.size = 64,
    this.animate = true,
    this.floatDistance = 6.0,
  });

  final MascotMood mood;
  final double size;
  final bool animate;
  final double floatDistance;

  @override
  State<MascotAvatar> createState() => _MascotAvatarState();
}

class _MascotAvatarState extends State<MascotAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      widget.mood.assetPath,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );

    if (!widget.animate) return image;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -widget.floatDistance * _controller.value),
          child: child,
        );
      },
      child: image,
    );
  }
}

/// A mascot with a speech bubble message — perfect for companion tips.
class MascotBubble extends StatelessWidget {
  const MascotBubble({
    super.key,
    required this.message,
    this.mood = MascotMood.wink,
    this.mascotSize = 56,
    this.bubbleColor,
    this.textColor,
    this.borderColor,
  });

  final String message;
  final MascotMood mood;
  final double mascotSize;
  final Color? bubbleColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBubbleColor =
        bubbleColor ?? Colors.white.withValues(alpha: .82);
    final effectiveTextColor = textColor ?? Theme.of(context).colorScheme.onSurface;
    final effectiveBorderColor =
        borderColor ?? Colors.white.withValues(alpha: .92);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MascotAvatar(mood: mood, size: mascotSize),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: effectiveBubbleColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
                topLeft: Radius.circular(4),
              ),
              border: Border.all(color: effectiveBorderColor),
            ),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: effectiveTextColor,
                    height: 1.4,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A full mascot companion card with a glass card background.
/// Used as a section-level component in pages.
class MascotCompanionCard extends StatelessWidget {
  const MascotCompanionCard({
    super.key,
    required this.title,
    required this.message,
    this.mood = MascotMood.wink,
    this.mascotSize = 62,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  final String title;
  final String message;
  final MascotMood mood;
  final double mascotSize;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: .74),
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: .92),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: mascotSize + 16,
              height: mascotSize + 16,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .86),
                borderRadius: BorderRadius.circular(20),
              ),
              child: MascotAvatar(mood: mood, size: mascotSize, floatDistance: 4),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A dark-themed mascot companion card for the Sleep page.
class MascotCompanionCardDark extends StatelessWidget {
  const MascotCompanionCardDark({
    super.key,
    required this.title,
    required this.message,
    this.mood = MascotMood.think,
    this.mascotSize = 56,
  });

  final String title;
  final String message;
  final MascotMood mood;
  final double mascotSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF0F172A),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: mascotSize + 16,
            height: mascotSize + 16,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFC084FC).withValues(alpha: 0.15),
              ),
            ),
            child: MascotAvatar(mood: mood, size: mascotSize, floatDistance: 4),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
