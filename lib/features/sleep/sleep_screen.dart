import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/providers/health_score_provider.dart';

import 'providers/sleep_provider.dart';
import '../../shared/widgets/mascot_helper.dart';
import 'widgets/sleep_hero_section.dart';
import 'widgets/sleep_score_card.dart';
import 'widgets/sleep_plan_card.dart';
import 'widgets/sleep_journey_visualization.dart';
import 'widgets/weekly_sleep_garden.dart';
import 'widgets/relaxation_tools.dart';
import 'widgets/sleep_streak_card.dart';
import 'widgets/sleep_achievements.dart';
import 'widgets/sleep_input_sheet.dart';

class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({super.key});

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 00);
  TimeOfDay _wake = const TimeOfDay(hour: 6, minute: 00);

  double get _expectedHours {
    var sleepDate = DateTime(2026, 1, 1, _bedtime.hour, _bedtime.minute);
    var wakeDate = DateTime(2026, 1, 1, _wake.hour, _wake.minute);
    if (!wakeDate.isAfter(sleepDate)) {
      wakeDate = wakeDate.add(const Duration(days: 1));
    }
    return wakeDate.difference(sleepDate).inMinutes / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(sleepProvider);
    final status = ref.read(sleepProvider.notifier).patternStatus();

    final latestRecord = records.isNotEmpty ? records.last : null;
    final sleepScore = latestRecord?.score ?? 87;
    final sleepStatus = latestRecord != null
        ? (latestRecord.score >= 85
            ? 'Excellent Sleep'
            : latestRecord.score >= 60
                ? 'Good Sleep'
                : 'Poor Sleep')
        : 'Excellent Sleep';

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        cardColor: const Color(0xFF0F172A),
        textTheme: const TextTheme(
          displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
          bodySmall: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF090D1A), // Midnight Dark Navy
              Color(0xFF0F172A), // Slate Navy
              Color(0xFF1E1B4B), // Deep Indigo
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Sleep Companion',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white70),
                onPressed: () => _showTipsDialog(context),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.icon(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => SleepInputSheet(
                        onSave: (sleep, wake) =>
                            ref.read(sleepProvider.notifier).saveToday(sleep, wake),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6), // Purple accent
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Log Sleep', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                // 1. Hero Section
                SleepHeroSection(
                  sleepGoalHours: 8.0,
                  bedtime: _bedtime,
                  wakeUpTime: _wake,
                ),
                const SizedBox(height: 16),

                // 2. Motivation Section
                const _MotivationCard(),
                const SizedBox(height: 20),

                // 3. Sleep Score Card
                SleepScoreCard(
                  score: sleepScore,
                  status: sleepStatus,
                ),
                const SizedBox(height: 20),

                // 4. Tonight's Sleep Plan
                SleepPlanCard(
                  bedtime: _bedtime,
                  wakeTime: _wake,
                  expectedHours: _expectedHours,
                  onEditPlan: (sleep, wake) {
                    setState(() {
                      _bedtime = sleep;
                      _wake = wake;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 5. Sleep Journey Visualization
                const SleepJourneyVisualization(),
                const SizedBox(height: 20),

                // 6. Weekly Sleep Garden
                WeeklySleepGarden(records: records),
                const SizedBox(height: 20),

                // 7. Sleep Insights
                _SleepInsightsPanel(patternStatus: status),
                const SizedBox(height: 20),

                // 8. Sleep Streak Card
                SleepStreakCard(streakDays: ref.watch(healthScoreProvider).goodStreakDays),
                const SizedBox(height: 20),

                // 9. Sleep Achievement System
                const SleepAchievements(),
                const SizedBox(height: 20),

                // 10. Relaxation Tools
                const RelaxationTools(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTipsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Sleep Guide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'A healthy sleep routine keeps your Vitality Tree blooming. Try to maintain a consistent bedtime, wind down with relaxation sounds, and aim for 8 hours of rest each night.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it', style: TextStyle(color: Color(0xFFC084FC))),
          ),
        ],
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  const _MotivationCard();

  @override
  Widget build(BuildContext context) {
    return const MascotCompanionCardDark(
      title: "Night Routine Companion",
      message: "You're only 1 good night away from your next reward. Sleep before 22:00 to keep your streak.",
      mood: MascotMood.wink,
    );
  }
}

class _SleepInsightsPanel extends StatelessWidget {
  const _SleepInsightsPanel({required this.patternStatus});

  final String patternStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0F172A),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sleep Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Icon(Icons.psychology_outlined, color: Color(0xFFFEF08A), size: 20),
            ],
          ),
          const SizedBox(height: 18),
          const _InsightItem(
            icon: Icons.check_circle_outline,
            iconColor: Color(0xFF34D399),
            text: 'You slept 45 minutes longer than yesterday',
          ),
          const SizedBox(height: 12),
          const _InsightItem(
            icon: Icons.check_circle_outline,
            iconColor: Color(0xFF34D399),
            text: 'Your sleep quality improved this week',
          ),
          const SizedBox(height: 12),
          _InsightItem(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFBBF24),
            text: _consistencyText(patternStatus),
          ),
        ],
      ),
    );
  }

  String _consistencyText(String status) {
    return switch (status) {
      'Stable' => 'Bedtime consistency is excellent and stable!',
      'Irregular' => 'Bedtime consistency can be improved',
      'Insufficient' => 'Daily sleep duration is currently low',
      'Excessive' => 'Daily sleep duration is longer than average',
      _ => 'Keep logging to unlock detailed consistency insights',
    };
  }
}

class _InsightItem extends StatelessWidget {
  const _InsightItem({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
