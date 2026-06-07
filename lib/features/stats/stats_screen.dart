import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/mascot_helper.dart';
import '../home/providers/health_score_provider.dart';
import 'providers/stats_provider.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/heatmap_calendar.dart';
import 'widgets/journey_chart.dart';
import 'widgets/milestone_timeline.dart';
import 'widgets/stats_bento_grid.dart';
import 'widgets/stats_header_card.dart';
import 'widgets/stats_insights_panel.dart';
import 'widgets/stats_sleep_analysis.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(statsProvider);
    final score = ref.watch(healthScoreProvider);
    final isEmptyState = reports.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistik',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 800));
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              if (isEmptyState) ...[
                const EmptyStateView(),
              ] else ...[
                // 1. Gamified Header Banner
                StatsHeaderCard(score: score),
                const SizedBox(height: 20),

                // 2. Bento Grid Quick Summary
                const StatsBentoGrid(),
                const SizedBox(height: 20),

                // 3. Health Journey Chart (Interactive line chart w/ period toggle)
                const JourneyChart(),
                const SizedBox(height: 20),

                // 4. Sleep Analysis Section
                const StatsSleepAnalysis(),
                const SizedBox(height: 20),

                // 5. Consistency Heatmap Calendar
                HeatmapCalendar(reports: reports),
                const SizedBox(height: 20),

                // 6. Smart Insights Panel
                const StatsInsightsPanel(),
                const SizedBox(height: 20),

                // 6.5. Mascot Companion Insight
                MascotCompanionCard(
                  mood: score.total >= 75
                      ? MascotMood.excited
                      : score.total >= 50
                          ? MascotMood.wink
                          : MascotMood.think,
                  title: 'Mira says...',
                  message: _statsMascotMessage(score.total),
                ),
                const SizedBox(height: 20),

                // 7. Milestones Timeline
                const MilestoneTimeline(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _statsMascotMessage(int score) {
  if (score >= 85) {
    return 'Luar biasa! Skor kesehatanmu mencapai $score. Pertahankan performa luar biasa ini!';
  } else if (score >= 60) {
    return 'Kerja bagus! Skor kesehatanmu $score. Sedikit peningkatan lagi dan kamu akan mencapai performa terbaik!';
  } else {
    return 'Kamu berada di jalur yang benar! Terus catat aktivitas harianmu untuk meningkatkan skor kesehatanmu.';
  }
}
