import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/daily_quest.dart';
import 'providers/quest_provider.dart';
import 'widgets/quest_timer_sheet.dart';
import '../../shared/widgets/mascot_helper.dart';

class QuestScreen extends ConsumerStatefulWidget {
  const QuestScreen({super.key});

  @override
  ConsumerState<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends ConsumerState<QuestScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebrationController;
  String? _celebratedQuestId;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _startQuest(DailyQuest quest) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => QuestTimerSheet(
        quest: quest,
        onComplete: () {
          ref.read(questProvider.notifier).complete(quest.id);
          HapticFeedback.mediumImpact();
          setState(() => _celebratedQuestId = quest.id);
          _celebrationController.forward(from: 0);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questProvider);
    final completed = state.quests.where((quest) => quest.completed).length;
    final total = state.quests.length;
    final dailyProgress = total == 0 ? 0.0 : completed / total;
    final xpToday = completed * 80;
    const nextLevelXp = 500;
    final levelProgress = (xpToday / nextLevelXp).clamp(0.0, 1.0);

    return Stack(
      children: [
        const _QuestBackdrop(),
        ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            _QuestHeader(
              streak: state.streak,
              xpToday: xpToday,
              progress: dailyProgress,
            ),
            const SizedBox(height: 14),
            _SmartMotivationCard(
              completed: completed,
              total: total,
              xpToLevel: (nextLevelXp - xpToday).clamp(0, nextLevelXp),
            ),
            const SizedBox(height: 16),
            _SectionHeader(
              title: 'Daily quests',
              action: '$completed/$total complete',
            ),
            const SizedBox(height: 10),
            for (final quest in state.quests) ...[
              _DailyQuestCard(
                quest: quest,
                rewardXp: 80,
                celebrated: _celebratedQuestId == quest.id,
                onStart: () => _startQuest(quest),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            const _SectionHeader(
                title: 'Weekly quests', action: 'Premium goals'),
            const SizedBox(height: 10),
            SizedBox(
              height: 166,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _WeeklyQuestCard(
                    title: 'Exercise 4 times',
                    subtitle: 'Weekly movement mission',
                    progress: .50,
                    reward: 'Rare badge',
                    icon: Icons.directions_run,
                    color: AppColors.green600,
                  ),
                  SizedBox(width: 12),
                  _WeeklyQuestCard(
                    title: 'Sleep well 5 days',
                    subtitle: 'Recovery streak mission',
                    progress: .72,
                    reward: '120 coins',
                    icon: Icons.bedtime_outlined,
                    color: AppColors.cyan700,
                  ),
                  SizedBox(width: 12),
                  _WeeklyQuestCard(
                    title: 'Drink 40 glasses',
                    subtitle: 'Hydration mission',
                    progress: .64,
                    reward: 'Avatar glow',
                    icon: Icons.water_drop_outlined,
                    color: AppColors.cyan600,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _SectionHeader(
                title: 'Monthly challenge', action: 'Seasonal'),
            const SizedBox(height: 10),
            const _MonthlyChallengeRow(),
            const SizedBox(height: 16),
            _RewardTrack(levelProgress: levelProgress, xpToday: xpToday),
            const SizedBox(height: 16),
            const _SectionHeader(
                title: 'Achievement gallery', action: 'Rarity'),
            const SizedBox(height: 10),
            const _AchievementGallery(),
            const SizedBox(height: 16),
            const _DailyLoginReward(),
            const SizedBox(height: 16),
            _StreakSystemCard(streak: state.streak),
          ],
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _celebrationController,
            builder: (context, _) {
              return CustomPaint(
                painter:
                    _ConfettiPainter(progress: _celebrationController.value),
                size: Size.infinite,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuestHeader extends StatefulWidget {
  const _QuestHeader({
    required this.streak,
    required this.xpToday,
    required this.progress,
  });

  final int streak;
  final int xpToday;
  final double progress;

  @override
  State<_QuestHeader> createState() => _QuestHeaderState();
}

class _QuestHeaderState extends State<_QuestHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      radius: 28,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Quest',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 5),
                Text(
                  'Complete small health missions and protect today\'s streak.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatChip(
                      icon: Icons.local_fire_department_outlined,
                      label: '${widget.streak} Day Streak',
                      color: AppColors.amber300,
                    ),
                    _StatChip(
                      icon: Icons.star_rounded,
                      label: '${widget.xpToday} XP Today',
                      color: AppColors.cyan700,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.pill),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    minHeight: 10,
                    color: AppColors.green400,
                    backgroundColor: AppColors.green50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -7 * _controller.value),
                child: Transform.scale(
                  scale: .98 + _controller.value * .04,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 92,
              height: 92,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cyan50,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const MascotAvatar(
                mood: MascotMood.excited,
                size: 76,
                animate: false, // Let the parent AnimatedBuilder control custom bouncy movement
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuestCard extends StatefulWidget {
  const _DailyQuestCard({
    required this.quest,
    required this.rewardXp,
    required this.celebrated,
    required this.onStart,
  });

  final DailyQuest quest;
  final int rewardXp;
  final bool celebrated;
  final VoidCallback onStart;

  @override
  State<_DailyQuestCard> createState() => _DailyQuestCardState();
}

class _DailyQuestCardState extends State<_DailyQuestCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.xslow,
    );
    if (widget.quest.completed) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _DailyQuestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.quest.completed && widget.quest.completed) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.quest.completed;
    final color = _questColor(widget.quest.category);
    final progress = completed ? 1.0 : .34;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bounce = widget.celebrated
            ? 1 + math.sin(_controller.value * math.pi) * .035
            : 1.0;
        return Transform.scale(scale: bounce, child: child);
      },
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.curve,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: completed
              ? AppColors.green50.withValues(alpha: .86)
              : Colors.white.withValues(alpha: .78),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: completed
                ? AppColors.green400.withValues(alpha: .42)
                : Colors.white.withValues(alpha: .92),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: completed ? .16 : .10),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _QuestIcon(
                  icon: completed
                      ? Icons.check_rounded
                      : _iconFor(widget.quest.category),
                  color: completed ? AppColors.green600 : color,
                  completed: completed,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.quest.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_categoryLabel(widget.quest.category)} · ${widget.quest.durationMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _XpRewardChip(xp: widget.rewardXp, color: color),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.pill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      color: completed ? AppColors.green400 : color,
                      backgroundColor: AppColors.cyan50,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: completed ? null : widget.onStart,
                  icon: Icon(completed
                      ? Icons.verified_rounded
                      : Icons.play_arrow_rounded),
                  label: Text(completed ? 'Claimed' : 'Start'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyQuestCard extends StatelessWidget {
  const _WeeklyQuestCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.reward,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String reward;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: _GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 7,
                        color: color,
                        backgroundColor: AppColors.cyan50,
                      ),
                      Center(
                        child: Icon(icon, color: color, size: 22),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 3),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            _RewardPreview(label: reward, color: color),
          ],
        ),
      ),
    );
  }
}

class _MonthlyChallengeRow extends StatelessWidget {
  const _MonthlyChallengeRow();

  @override
  Widget build(BuildContext context) {
    const challenges = [
      _ChallengeData('Health Warrior', 'Finish 60 daily quests',
          Icons.shield_outlined, AppColors.amber300),
      _ChallengeData('Wellness Champion', 'Keep 20 mindful days',
          Icons.spa_outlined, AppColors.green600),
      _ChallengeData('Fitness Master', 'Build 12 active sessions',
          Icons.fitness_center, AppColors.pink400),
    ];
    return SizedBox(
      height: 142,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: challenges.length,
        separatorBuilder: (context, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = challenges[index];
          return SizedBox(
            width: 190,
            child: _GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconBubble(icon: item.icon, color: item.color),
                  const Spacer(),
                  Text(item.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RewardTrack extends StatelessWidget {
  const _RewardTrack({required this.levelProgress, required this.xpToday});

  final double levelProgress;
  final int xpToday;

  @override
  Widget build(BuildContext context) {
    const rewards = [
      _RewardNodeData('Level 1', '100 XP', Icons.monetization_on_outlined,
          AppColors.amber300, true),
      _RewardNodeData(
          'Level 2', '250 XP', Icons.park_outlined, AppColors.green600, false),
      _RewardNodeData(
          'Level 3', '500 XP', Icons.badge_outlined, AppColors.cyan700, false),
      _RewardNodeData(
          'Level 4', '800 XP', Icons.auto_awesome, AppColors.pink400, false),
    ];
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Reward track',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              _StatChip(
                icon: Icons.bolt_outlined,
                label: '$xpToday XP',
                color: AppColors.cyan700,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.pill),
            child: LinearProgressIndicator(
              value: levelProgress,
              minHeight: 12,
              color: AppColors.amber300,
              backgroundColor: AppColors.cyan50,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: rewards.length,
              separatorBuilder: (context, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _RewardNode(data: rewards[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardNode extends StatelessWidget {
  const _RewardNode({required this.data});

  final _RewardNodeData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: data.unlocked
              ? data.color.withValues(alpha: .14)
              : Colors.white.withValues(alpha: .66),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: data.unlocked
                ? data.color.withValues(alpha: .36)
                : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBubble(icon: data.icon, color: data.color, small: true),
              const Spacer(),
              Text(data.level, style: Theme.of(context).textTheme.titleMedium),
              Text(data.xp, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementGallery extends StatelessWidget {
  const _AchievementGallery();

  @override
  Widget build(BuildContext context) {
    const achievements = [
      _AchievementData('First Healthy Day', 'Common', Icons.flag_outlined,
          Color(0xFF8FA195)),
      _AchievementData('7 Day Streak', 'Rare',
          Icons.local_fire_department_outlined, AppColors.cyan700),
      _AchievementData(
          '30 Day Streak', 'Epic', Icons.auto_awesome, AppColors.pink400),
      _AchievementData('100 Quests', 'Legendary', Icons.emoji_events_outlined,
          AppColors.amber300),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.28,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _GlassCard(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconBubble(icon: achievement.icon, color: achievement.color),
                  const Spacer(),
                  _RarityPill(
                      label: achievement.rarity, color: achievement.color),
                ],
              ),
              const Spacer(),
              Text(achievement.title,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text('Achievement badge',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}

class _DailyLoginReward extends StatelessWidget {
  const _DailyLoginReward();

  @override
  Widget build(BuildContext context) {
    const rewards = [
      _LoginRewardData('Day 1', 'XP', Icons.star_rounded, true),
      _LoginRewardData('Day 2', 'Coins', Icons.monetization_on_outlined, true),
      _LoginRewardData('Day 3', 'Badge', Icons.badge_outlined, false),
      _LoginRewardData('Day 7', 'Special', Icons.card_giftcard_outlined, false),
    ];
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Daily login reward',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              FilledButton.icon(
                onPressed: () => HapticFeedback.lightImpact(),
                icon: const Icon(Icons.redeem_outlined),
                label: const Text('Claim'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < rewards.length; i++) ...[
                Expanded(child: _LoginRewardTile(data: rewards[i])),
                if (i != rewards.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakSystemCard extends StatelessWidget {
  const _StreakSystemCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final bestStreak = math.max(streak, 12);
    final nextReward = streak + (7 - streak % 7);
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconBubble(
                icon: Icons.local_fire_department,
                color: AppColors.amber300,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Streak system',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child:
                      _StreakMetric(label: 'Current', value: '$streak days')),
              const SizedBox(width: 10),
              Expanded(
                  child:
                      _StreakMetric(label: 'Best', value: '$bestStreak days')),
              const SizedBox(width: 10),
              Expanded(
                  child: _StreakMetric(
                      label: 'Next reward', value: 'Day $nextReward')),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Complete today\'s quest to maintain your streak.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SmartMotivationCard extends StatelessWidget {
  const _SmartMotivationCard({
    required this.completed,
    required this.total,
    required this.xpToLevel,
  });

  final int completed;
  final int total;
  final int xpToLevel;

  @override
  Widget build(BuildContext context) {
    final remaining = (total - completed).clamp(0, total);
    final message = remaining == 0
        ? 'Perfect day. Your rewards are secured.'
        : remaining == 1
            ? 'Only 1 quest left today.'
            : 'Complete $remaining more quests to level up faster.';
    return _GlassCard(
      padding: const EdgeInsets.all(14),
      radius: 22,
      child: Row(
        children: [
          const MascotAvatar(
            mood: MascotMood.wink,
            size: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '$xpToLevel XP left to the next reward tier.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginRewardTile extends StatelessWidget {
  const _LoginRewardTile({required this.data});

  final _LoginRewardData data;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 7),
      decoration: BoxDecoration(
        color: data.claimed
            ? AppColors.green50.withValues(alpha: .86)
            : Colors.white.withValues(alpha: .70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.claimed ? AppColors.green100 : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            data.claimed ? Icons.check_circle : data.icon,
            color: data.claimed ? AppColors.green600 : AppColors.cyan700,
          ),
          const SizedBox(height: 7),
          Text(data.day, style: Theme.of(context).textTheme.bodySmall),
          Text(
            data.reward,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

class _StreakMetric extends StatelessWidget {
  const _StreakMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.amber100.withValues(alpha: .20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 3),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        Text(
          action,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.cyan700,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(AppDimens.pill),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 5),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuestIcon extends StatelessWidget {
  const _QuestIcon({
    required this.icon,
    required this.color,
    required this.completed,
  });

  final IconData icon;
  final Color color;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(18),
        border:
            completed ? Border.all(color: color.withValues(alpha: .32)) : null,
      ),
      child: Icon(icon, color: color, size: 27),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.color,
    this.small = false,
  });

  final IconData icon;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 36.0 : 44.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(small ? 13 : 16),
      ),
      child: Icon(icon, color: color, size: small ? 19 : 23),
    );
  }
}

class _XpRewardChip extends StatelessWidget {
  const _XpRewardChip({required this.xp, required this.color});

  final int xp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppDimens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            Icon(Icons.star_rounded, color: color, size: 17),
            const SizedBox(width: 3),
            Text(
              '+$xp',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardPreview extends StatelessWidget {
  const _RewardPreview({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(AppDimens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _RarityPill extends StatelessWidget {
  const _RarityPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(AppDimens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .74),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: .92)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan700.withValues(alpha: .08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _QuestBackdrop extends StatelessWidget {
  const _QuestBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cyan50,
            Color(0xFFF7F2FF),
            AppColors.background,
          ],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final opacity = (1 - progress).clamp(0.0, 1.0);
    final colors = [
      AppColors.green400,
      AppColors.cyan600,
      AppColors.pink400,
      AppColors.amber300,
    ];
    for (var i = 0; i < 42; i++) {
      final seed = i * 29.0;
      final startX = size.width * ((math.sin(seed) + 1) / 2);
      final drift = math.sin(progress * math.pi + i) * 46;
      final y = size.height * (.18 + progress * .62) + (i % 7) * 8;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: opacity);
      canvas.save();
      canvas.translate(startX + drift, y);
      canvas.rotate(progress * math.pi * 2 + i);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 8, height: 14),
          const Radius.circular(3),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

IconData _iconFor(QuestCategory category) {
  return switch (category) {
    QuestCategory.meditation => Icons.self_improvement,
    QuestCategory.journaling => Icons.edit_note,
    QuestCategory.walking => Icons.directions_walk,
    QuestCategory.hydration => Icons.water_drop_outlined,
    QuestCategory.stretching => Icons.accessibility_new,
    QuestCategory.breathing => Icons.air,
    QuestCategory.gratitude => Icons.volunteer_activism_outlined,
  };
}

Color _questColor(QuestCategory category) {
  return switch (category) {
    QuestCategory.meditation => AppColors.pink400,
    QuestCategory.journaling => AppColors.cyan700,
    QuestCategory.walking => AppColors.green600,
    QuestCategory.hydration => AppColors.cyan600,
    QuestCategory.stretching => AppColors.amber300,
    QuestCategory.breathing => AppColors.cyan700,
    QuestCategory.gratitude => AppColors.pink400,
  };
}

String _categoryLabel(QuestCategory category) {
  return switch (category) {
    QuestCategory.meditation => 'Meditation',
    QuestCategory.journaling => 'Journal',
    QuestCategory.walking => 'Walking',
    QuestCategory.hydration => 'Hydration',
    QuestCategory.stretching => 'Stretching',
    QuestCategory.breathing => 'Breathing',
    QuestCategory.gratitude => 'Gratitude',
  };
}

class _ChallengeData {
  const _ChallengeData(this.title, this.subtitle, this.icon, this.color);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _RewardNodeData {
  const _RewardNodeData(
    this.level,
    this.xp,
    this.icon,
    this.color,
    this.unlocked,
  );

  final String level;
  final String xp;
  final IconData icon;
  final Color color;
  final bool unlocked;
}

class _AchievementData {
  const _AchievementData(this.title, this.rarity, this.icon, this.color);

  final String title;
  final String rarity;
  final IconData icon;
  final Color color;
}

class _LoginRewardData {
  const _LoginRewardData(this.day, this.reward, this.icon, this.claimed);

  final String day;
  final String reward;
  final IconData icon;
  final bool claimed;
}
