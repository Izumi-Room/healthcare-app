import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../models/daily_quest.dart';

class QuestTimerSheet extends StatefulWidget {
  const QuestTimerSheet({
    super.key,
    required this.quest,
    required this.onComplete,
  });

  final DailyQuest quest;
  final VoidCallback onComplete;

  @override
  State<QuestTimerSheet> createState() => _QuestTimerSheetState();
}

class _QuestTimerSheetState extends State<QuestTimerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.quest.durationMinutes * 60),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_completed) {
          _finish();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    setState(() => _completed = true);
    widget.onComplete();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.quest.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final remaining =
                  _controller.duration! * (1 - _controller.value);
              return SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: _controller.value,
                      strokeWidth: 12,
                      color: AppColors.green400,
                      backgroundColor: AppColors.green50,
                    ),
                    Center(
                      child: AnimatedSwitcher(
                        duration: AppAnimations.fast,
                        child: _completed
                            ? Column(
                                key: const ValueKey('done'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.green600,
                                    size: 44,
                                  ),
                                  Text('+80 XP',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ],
                              )
                            : Text(
                                _format(remaining),
                                key: const ValueKey('timer'),
                                style:
                                    Theme.of(context).textTheme.displaySmall,
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _completed ? null : _finish,
            icon: const Icon(Icons.check),
            label: const Text('Tandai selesai'),
          ),
        ],
      ),
    );
  }
}

String _format(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
