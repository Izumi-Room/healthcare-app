import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../providers/stats_provider.dart';

class MilestoneTimeline extends ConsumerWidget {
  const MilestoneTimeline({super.key, this.isEmptyState = false});

  final bool isEmptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestones = ref.watch(milestonesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Milestones',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFBBF24).withValues(alpha: .3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      '${milestones.where((m) => isEmptyState ? false : m.completed).length}/${milestones.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              final isLast = index == milestones.length - 1;
              final isCompleted =
                  isEmptyState ? index == 0 : milestone.completed;

              return _MilestoneItem(
                title: milestone.title,
                subtitle: milestone.subtitle,
                emoji: milestone.emoji,
                date: isCompleted ? milestone.date : 'Terkunci',
                isCompleted: isCompleted,
                isLast: isLast,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MilestoneItem extends StatefulWidget {
  const _MilestoneItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.date,
    required this.isCompleted,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final String date;
  final bool isCompleted;
  final bool isLast;

  @override
  State<_MilestoneItem> createState() => _MilestoneItemState();
}

class _MilestoneItemState extends State<_MilestoneItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _animController.forward();
    await _animController.reverse();

    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: widget.isCompleted
                  ? const Color(0xFFDCFCE7)
                  : AppColors.border.withValues(alpha: .3),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isCompleted
                    ? const Color(0xFF22C55E)
                    : AppColors.border,
                width: 2.5,
              ),
              boxShadow: widget.isCompleted
                  ? [
                      BoxShadow(
                        color:
                            const Color(0xFF22C55E).withValues(alpha: .25),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                widget.isCompleted ? widget.emoji : '🔒',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.isCompleted
                      ? const Color(0xFFDCFCE7)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.isCompleted
                        ? const Color(0xFF22C55E).withValues(alpha: .3)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  widget.isCompleted
                      ? '✅ Tercapai pada: ${widget.date}'
                      : '🔒 Lakukan aktivitas untuk membuka!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.isCompleted
                        ? const Color(0xFF166534)
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup',
                  style: TextStyle(color: AppColors.green600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        onTap: _onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline connector
              Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.isCompleted
                          ? const Color(0xFFDCFCE7)
                          : AppColors.border.withValues(alpha: .3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isCompleted
                            ? const Color(0xFF22C55E)
                            : AppColors.border,
                        width: 2.5,
                      ),
                      boxShadow: widget.isCompleted
                          ? [
                              BoxShadow(
                                color: const Color(0xFF22C55E)
                                    .withValues(alpha: .15),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.isCompleted ? widget.emoji : '🔒',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  if (!widget.isLast)
                    Container(
                      width: 2.5,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.isCompleted
                            ? const Color(0xFF86EFAC)
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.isCompleted
                        ? const Color(0xFFF0FDF4)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isCompleted
                          ? const Color(0xFF86EFAC).withValues(alpha: .5)
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: widget.isCompleted
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary
                                        .withValues(alpha: .5),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondary
                                        .withValues(alpha: .35),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.isCompleted
                                    ? const Color(0xFF22C55E)
                                        .withValues(alpha: .1)
                                    : AppColors.border
                                        .withValues(alpha: .3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.date,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.isCompleted
                                      ? const Color(0xFF166534)
                                      : AppColors.textSecondary
                                          .withValues(alpha: .4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: widget.isCompleted
                            ? AppColors.green400
                            : AppColors.border,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
