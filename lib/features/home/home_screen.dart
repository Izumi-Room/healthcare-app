import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets/mascot_helper.dart';

import '../../core/theme.dart';
import '../../models/health_score.dart';
import 'providers/health_score_provider.dart';
import 'widgets/tree_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(healthScoreProvider);
    final achievements = [
      _AchievementData(
        'Recent bloom',
        score.increased ? 'Vitality rose today' : 'Calm check-in saved',
        Icons.auto_awesome,
        AppColors.pink400,
      ),
      _AchievementData(
        'Longest streak',
        '${score.goodStreakDays.clamp(1, 30)} mindful days',
        Icons.local_fire_department_outlined,
        AppColors.amber300,
      ),
      _AchievementData(
        'Highest milestone',
        'Lv.${score.treeLevel.level} ${score.treeLevel.label}',
        Icons.emoji_events_outlined,
        AppColors.green600,
      ),
    ];
    final treeSignals = [
      _TreeSignalData(
        'Canopy vitality',
        '${score.total}%',
        score.total / 100,
        Icons.eco_outlined,
        AppColors.green600,
      ),
      _TreeSignalData(
        'Bloom readiness',
        '${(score.nextLevelProgress * 100).round()}%',
        score.nextLevelProgress,
        Icons.filter_vintage_outlined,
        score.treeLevel.blooms ? AppColors.pink400 : AppColors.amber300,
      ),
      _TreeSignalData(
        'Habitat energy',
        score.total >= 75 ? 'Radiant' : 'Growing',
        (score.activity + score.mood) / 50,
        Icons.wb_sunny_outlined,
        AppColors.cyan600,
      ),
      _TreeSignalData(
        'Reward pulse',
        score.nextLevelProgress > .72 ? 'Near' : 'Charging',
        score.nextLevelProgress,
        Icons.auto_awesome,
        AppColors.amber300,
      ),
    ];

    return Stack(
      children: [
        _DashboardBackdrop(score: score),
        ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            _HeroHeader(score: score),
            const SizedBox(height: 14),
            _TreeHero(score: score),
            const SizedBox(height: 16),
            _AchievementShowcase(items: achievements),
            const SizedBox(height: 16),
            _HealthCompanion(score: score),
            const SizedBox(height: 16),
            const _SectionHeader(
                title: 'Tree care signals', action: 'Live habitat'),
            const SizedBox(height: 10),
            _TreeSignalPanel(items: treeSignals),
            const SizedBox(height: 16),
            _JourneyPanel(score: score),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              const _RewardLab(),
            ],
          ],
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.score});

  final HealthScore score;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, d MMM').format(DateTime.now());
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                'Hi, Alya',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              Text(
                _motivationCopy(score),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryPill(
                    icon: Icons.eco_outlined,
                    label: '${score.total}% vitality',
                  ),
                  _SummaryPill(
                    icon: Icons.bolt_outlined,
                    label: 'Lv.${score.treeLevel.level}',
                  ),
                  _SummaryPill(
                    icon: Icons.favorite_outline,
                    label: '${score.goodStreakDays.clamp(1, 30)} day streak',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _UserAvatar(),
      ],
    );
  }
}

class _TreeHero extends StatelessWidget {
  const _TreeHero({required this.score});

  final HealthScore score;

  @override
  Widget build(BuildContext context) {
    final progress = (score.nextLevelProgress * 100).round();
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      radius: 30,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Health Tree',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _environmentCopy(score),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _EnvironmentChip(score: score),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TreeWidget(score: score),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tree evolution preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '$progress%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.cyan700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.pill),
            child: LinearProgressIndicator(
              value: score.nextLevelProgress,
              minHeight: 12,
              color: score.treeLevel.blooms
                  ? AppColors.pink400
                  : AppColors.green400,
              backgroundColor: Colors.white.withValues(alpha: .75),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementShowcase extends StatelessWidget {
  const _AchievementShowcase({required this.items});

  final List<_AchievementData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Featured achievements', action: 'Top 3'),
        const SizedBox(height: 10),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _AchievementCard(
              data: items[index],
              delay: index * .10,
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatefulWidget {
  const _AchievementCard({required this.data, required this.delay});

  final _AchievementData data;
  final double delay;

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final lift = mathWave((_controller.value + widget.delay) % 1) * 3;
        return Transform.translate(offset: Offset(0, -lift), child: child);
      },
      child: SizedBox(
        width: 150,
        child: _GlassCard(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _IconBubble(icon: widget.data.icon, color: widget.data.color),
              Text(widget.data.title,
                  style: Theme.of(context).textTheme.titleMedium),
              Text(widget.data.subtitle,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthCompanion extends StatefulWidget {
  const _HealthCompanion({required this.score});

  final HealthScore score;

  @override
  State<_HealthCompanion> createState() => _HealthCompanionState();
}

class _HealthCompanionState extends State<_HealthCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  MascotMood get _mascotMood {
    if (widget.score.isWilted) return MascotMood.think;
    if (widget.score.total >= 75) return MascotMood.excited;
    return MascotMood.wink;
  }

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -5 * _controller.value),
                child: child,
              );
            },
            child: Container(
              width: 68,
              height: 68,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .86),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                _mascotMood.assetPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mira, health companion',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  _mascotCopy(widget.score),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.35,
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

class _TreeSignalPanel extends StatelessWidget {
  const _TreeSignalPanel({required this.items});

  final List<_TreeSignalData> items;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(14),
      radius: 24,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _TreeSignalTile(data: items[0], featured: true)),
              const SizedBox(width: 10),
              Expanded(child: _TreeSignalTile(data: items[1], featured: true)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _TreeSignalTile(data: items[2])),
              const SizedBox(width: 10),
              Expanded(child: _TreeSignalTile(data: items[3])),
            ],
          ),
        ],
      ),
    );
  }
}

class _TreeSignalTile extends StatelessWidget {
  const _TreeSignalTile({required this.data, this.featured = false});

  final _TreeSignalData data;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      padding: EdgeInsets.all(featured ? 13 : 11),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: featured ? .13 : .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBubble(icon: data.icon, color: data.color, small: true),
              const Spacer(),
              Text(
                data.valueLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: data.color,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.label,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.pill),
            child: LinearProgressIndicator(
              value: data.progress.clamp(0, 1),
              minHeight: featured ? 9 : 7,
              color: data.color,
              backgroundColor: Colors.white.withValues(alpha: .74),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyPanel extends StatelessWidget {
  const _JourneyPanel({required this.score});

  final HealthScore score;

  @override
  Widget build(BuildContext context) {
    final rewardReady = score.nextLevelProgress > .72;
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Health journey progress',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              _RewardTag(ready: rewardReady),
            ],
          ),
          const SizedBox(height: 12),
          _GrowthSummary(score: score),
          const SizedBox(height: 12),
          _UnlockableRow(
            icon: Icons.filter_vintage_outlined,
            title: 'Upcoming unlockable',
            subtitle: score.treeLevel.level >= 6
                ? 'More butterflies and radiant flowers'
                : 'First bloom and companion reaction',
          ),
          const SizedBox(height: 10),
          _UnlockableRow(
            icon: Icons.card_giftcard_outlined,
            title: 'Milestone reward',
            subtitle: rewardReady
                ? 'Reward chest is almost ready'
                : 'Keep steady habits to open the next reward',
          ),
        ],
      ),
    );
  }
}

class _GrowthSummary extends StatelessWidget {
  const _GrowthSummary({required this.score});

  final HealthScore score;

  @override
  Widget build(BuildContext context) {
    final weeklyGain = (score.total - score.previousTotal).clamp(-25, 25);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.green50.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const _IconBubble(icon: Icons.trending_up, color: AppColors.green600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly growth summary',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  weeklyGain >= 0
                      ? '+$weeklyGain vitality since last update'
                      : '$weeklyGain vitality since last update',
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

class _UnlockableRow extends StatelessWidget {
  const _UnlockableRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBubble(icon: icon, color: AppColors.cyan700, small: true),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _RewardLab extends ConsumerWidget {
  const _RewardLab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GlassCard(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final key in ['sleep', 'mood', 'activity'])
            OutlinedButton(
              onPressed: () =>
                  ref.read(healthScoreProvider.notifier).demoAdjust(key, 4),
              child: Text('+$key'),
            ),
          OutlinedButton(
            onPressed: () => ref
                .read(healthScoreProvider.notifier)
                .demoAdjust('activity', -8),
            child: const Text('-activity'),
          ),
        ],
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

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .76),
        borderRadius: BorderRadius.circular(AppDimens.pill),
        border: Border.all(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.green600),
            const SizedBox(width: 5),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EnvironmentChip extends StatelessWidget {
  const _EnvironmentChip({required this.score});

  final HealthScore score;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final night = hour >= 18 || hour < 6;
    final icon = night
        ? Icons.nights_stay_outlined
        : score.total >= 75
            ? Icons.wb_sunny_outlined
            : Icons.cloud_queue_outlined;
    final label = night
        ? 'Night calm'
        : score.total >= 75
            ? 'Sunny'
            : 'Soft sky';
    return _SummaryPill(icon: icon, label: label);
  }
}

class _RewardTag extends StatelessWidget {
  const _RewardTag({required this.ready});

  final bool ready;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: (ready ? AppColors.amber100 : AppColors.cyan100)
            .withValues(alpha: .72),
        borderRadius: BorderRadius.circular(AppDimens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          ready ? 'Reward soon' : 'Building',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
      ),
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

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cyan100, AppColors.green100],
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan700.withValues(alpha: .12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset('assets/mascot/wink.png', fit: BoxFit.contain),
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
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: .92)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan700.withValues(alpha: .09),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashboardBackdrop extends StatelessWidget {
  const _DashboardBackdrop({required this.score});

  final HealthScore score;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final night = hour >= 18 || hour < 6;
    final colors = night
        ? const [Color(0xFF123047), Color(0xFFE8F8F3), AppColors.background]
        : score.total >= 75
            ? const [Color(0xFFFFF7D6), Color(0xFFE7FAFF), AppColors.background]
            : const [AppColors.cyan50, Color(0xFFEFF8E7), AppColors.background];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _AchievementData {
  const _AchievementData(this.title, this.subtitle, this.icon, this.color);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _TreeSignalData {
  const _TreeSignalData(
    this.label,
    this.valueLabel,
    this.progress,
    this.icon,
    this.color,
  );

  final String label;
  final String valueLabel;
  final double progress;
  final IconData icon;
  final Color color;
}

double mathWave(double value) {
  return (1 - (value * 2 - 1).abs()).clamp(0.0, 1.0);
}

String _motivationCopy(HealthScore score) {
  if (score.isWilted) {
    return 'A gentle reset is enough to help your tree recover.';
  }
  if (score.total >= 75) {
    return 'Your tree feels bright today. Keep the rhythm soft.';
  }
  return 'Small care today becomes visible growth tomorrow.';
}

String _environmentCopy(HealthScore score) {
  if (score.isWilted) {
    return 'Clouds gather, but your next check-in can calm the grove.';
  }
  if (score.treeLevel.level >= 8) {
    return 'Sunlight, flowers, and wildlife are responding to your care.';
  }
  if (score.treeLevel.blooms) {
    return 'Butterflies begin to visit as your tree reaches bloom stages.';
  }
  return 'Soft leaves and garden light grow with each healthy habit.';
}

String _mascotCopy(HealthScore score) {
  if (score.sleep < 15) {
    return 'Your tree wants deeper rest. Try a calmer bedtime checkpoint tonight.';
  }
  if (score.activity < 15) {
    return 'A short walk can wake up the grove and add fresh motion around the tree.';
  }
  if (score.total >= 75) {
    return 'Beautiful momentum. One small care action can trigger another bloom.';
  }
  return 'You are close to the next growth stage. Choose the easiest healthy action first.';
}
