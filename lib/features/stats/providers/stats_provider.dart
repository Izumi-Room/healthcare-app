import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/health_report.dart';
import '../../home/providers/health_score_provider.dart';

// Period provider: Daily, Weekly, Monthly
final reportPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.daily);

final statsProvider = Provider<List<HealthDayReport>>((ref) {
  final score = ref.watch(healthScoreProvider);
  if (score.total == 0) return const [];

  return [
    HealthDayReport(
      date: score.updatedAt,
      score: score.total,
      sleep: score.sleep,
      quest: score.quest,
      mood: score.mood,
      activity: score.activity,
      consistency: score.goodStreakDays > 0 ? 100 : 0,
    ),
  ];
});

final weeklyStatsProvider = Provider<List<HealthDayReport>>((ref) {
  return ref.watch(statsProvider);
});

final monthlyStatsProvider = Provider<List<HealthDayReport>>((ref) {
  return ref.watch(statsProvider);
});

// Traditional trend metrics
final trendProvider = Provider<List<TrendMetric>>((ref) {
  final score = ref.watch(healthScoreProvider);
  return [
    TrendMetric('Tidur', score.sleep, score.sleep),
    TrendMetric('Quest', score.quest, score.quest),
    TrendMetric('Mood', score.mood, score.mood),
    TrendMetric('Aktivitas', score.activity, score.activity),
  ];
});

// Growth analytics comparing current period to previous (percentages)
class GrowthMetric {
  const GrowthMetric({
    required this.label,
    required this.improvementPercent,
    required this.subtitle,
    required this.category,
  });
  final String label;
  final int improvementPercent;
  final String subtitle;
  final String category;
}

final growthAnalyticsProvider = Provider<List<GrowthMetric>>((ref) {
  return const [];
});

// Milestone data models
class HealthMilestone {
  const HealthMilestone({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.completed,
    required this.date,
  });
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final bool completed;
  final String date;
}

final milestonesProvider = Provider<List<HealthMilestone>>((ref) {
  return const [];
});

// Future Goals
class HealthGoal {
  const HealthGoal({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.reward,
  });
  final String id;
  final String title;
  final int progress;
  final int target;
  final String reward;

  double get percent => (progress / target).clamp(0.0, 1.0);
}

final futureGoalsProvider = Provider<List<HealthGoal>>((ref) {
  return const [];
});

// Smart Insights model
class SmartInsight {
  const SmartInsight({
    required this.bestDay,
    required this.bestDayScore,
    required this.topCategory,
    required this.avgScore,
    required this.recommendation,
    required this.totalLearningMinutes,
    required this.weeklyTrend,
  });
  final String bestDay;
  final int bestDayScore;
  final String topCategory;
  final int avgScore;
  final String recommendation;
  final int totalLearningMinutes;
  final double weeklyTrend; // positive = improving, negative = declining
}

// Derives learning time estimate from quest contributions (each quest point ≈ 4 minutes)
final learningTimeProvider = Provider<int>((ref) {
  final reports = ref.watch(statsProvider);
  final totalQuestPoints = reports.fold<int>(0, (sum, r) => sum + r.quest);
  return (totalQuestPoints * 4).clamp(0, 9999); // in minutes
});

// Derives smart insights from the last 30 days of data
final insightsProvider = Provider<SmartInsight>((ref) {
  final reports = ref.watch(statsProvider);
  final score = ref.watch(healthScoreProvider);

  if (reports.isEmpty) {
    return const SmartInsight(
      bestDay: 'N/A',
      bestDayScore: 0,
      topCategory: 'Tidur',
      avgScore: 0,
      recommendation: 'Mulai catat aktivitas untuk melihat insight personalmu!',
      totalLearningMinutes: 0,
      weeklyTrend: 0,
    );
  }

  // Find best day
  final best = reports.reduce((a, b) => a.score > b.score ? a : b);
  final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  final bestDay = days[best.date.weekday - 1];

  // Average score
  final avgScore =
      (reports.fold<int>(0, (s, r) => s + r.score) / reports.length).round();

  // Top category
  final avgSleep =
      reports.fold<int>(0, (s, r) => s + r.sleep) ~/ reports.length;
  final avgQuest =
      reports.fold<int>(0, (s, r) => s + r.quest) ~/ reports.length;
  final avgMood = reports.fold<int>(0, (s, r) => s + r.mood) ~/ reports.length;
  final avgActivity =
      reports.fold<int>(0, (s, r) => s + r.activity) ~/ reports.length;

  final categoryScores = {
    'Tidur': avgSleep,
    'Quest': avgQuest,
    'Mood': avgMood,
    'Aktivitas': avgActivity,
  };
  final topCategory =
      categoryScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

  // Weekly trend (last 7 vs previous 7)
  final last7 =
      reports.length >= 7 ? reports.sublist(reports.length - 7) : reports;
  final prev7 = reports.length >= 14
      ? reports.sublist(reports.length - 14, reports.length - 7)
      : <HealthDayReport>[];
  final lastAvg = last7.fold<int>(0, (s, r) => s + r.score) / last7.length;
  final prevAvg = prev7.isEmpty
      ? lastAvg
      : prev7.fold<int>(0, (s, r) => s + r.score) / prev7.length;
  final weeklyTrend = lastAvg - prevAvg;

  // Smart recommendation
  String recommendation;
  if (score.sleep < 15) {
    recommendation =
        'Tidur kamu masih perlu ditingkatkan. Coba tidur lebih awal 30 menit malam ini!';
  } else if (score.quest < 15) {
    recommendation =
        'Kamu hampir di puncak performa! Selesaikan 1 quest lagi hari ini.';
  } else if (score.mood < 15) {
    recommendation =
        'Mood kamu bisa lebih baik. Coba 5 menit meditasi dengan alat relaksasi.';
  } else {
    recommendation =
        'Performa kamu luar biasa! Pertahankan konsistensi untuk naik level. 🌟';
  }

  final totalLearningMins = reports.fold<int>(0, (s, r) => s + r.quest) * 4;

  return SmartInsight(
    bestDay: bestDay,
    bestDayScore: best.score,
    topCategory: topCategory,
    avgScore: avgScore,
    recommendation: recommendation,
    totalLearningMinutes: totalLearningMins,
    weeklyTrend: weeklyTrend,
  );
});
