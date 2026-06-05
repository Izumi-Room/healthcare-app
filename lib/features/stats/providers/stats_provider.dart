import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/health_report.dart';
import '../../home/providers/health_score_provider.dart';

// Period provider: Daily, Weekly, Monthly
final reportPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.daily);

// Toggle to simulate Empty State for testing onboarding
final statsEmptyStateProvider = StateProvider<bool>((ref) => false);

// 30 days of data for the sparklines and charts
final statsProvider = Provider<List<HealthDayReport>>((ref) {
  final score = ref.watch(healthScoreProvider);
  final today = DateTime.now();
  return [
    for (var i = 29; i >= 0; i--)
      _reportForDay(today.subtract(Duration(days: i)), score.total, i),
  ];
});

// Weekly summary data
final weeklyStatsProvider = Provider<List<HealthDayReport>>((ref) {
  final today = DateTime.now();
  final list = <HealthDayReport>[];
  for (var i = 4; i >= 0; i--) {
    final date = today.subtract(Duration(days: i * 7));
    // simulate weekly avg scores
    final score = (78 - i * 4).clamp(40, 95);
    list.add(HealthDayReport(
      date: date,
      score: score,
      sleep: (score * .24).round().clamp(10, 25),
      quest: (score * .23).round().clamp(10, 25),
      mood: (score * .25).round().clamp(10, 25),
      activity: (score * .22).round().clamp(10, 25),
      consistency: (score * .8).round(),
      hydration: (score * .95).round().clamp(50, 100),
      nutrition: (score * .88).round().clamp(45, 100),
    ));
  }
  return list;
});

// Monthly summary data
final monthlyStatsProvider = Provider<List<HealthDayReport>>((ref) {
  final today = DateTime.now();
  final list = <HealthDayReport>[];
  for (var i = 5; i >= 0; i--) {
    final date = DateTime(today.year, today.month - i, 1);
    final score = (82 - i * 6).clamp(50, 98);
    list.add(HealthDayReport(
      date: date,
      score: score,
      sleep: (score * .24).round().clamp(10, 25),
      quest: (score * .23).round().clamp(10, 25),
      mood: (score * .25).round().clamp(10, 25),
      activity: (score * .22).round().clamp(10, 25),
      consistency: (score * .8).round(),
      hydration: (score * .95).round().clamp(50, 100),
      nutrition: (score * .88).round().clamp(45, 100),
    ));
  }
  return list;
});

// Traditional trend metrics
final trendProvider = Provider<List<TrendMetric>>((ref) {
  final score = ref.watch(healthScoreProvider);
  return [
    TrendMetric('Tidur', score.sleep, 17),
    TrendMetric('Quest', score.quest, 12),
    TrendMetric('Mood', score.mood, 16),
    TrendMetric('Aktivitas', score.activity, 14),
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
  return const [
    GrowthMetric(
      label: '+15% Better Sleep',
      improvementPercent: 15,
      subtitle: 'Avg sleep duration increased by 45 mins',
      category: 'sleep',
    ),
    GrowthMetric(
      label: '+20% More Water Intake',
      improvementPercent: 20,
      subtitle: 'Reached hydration goal 6 days this week',
      category: 'hydration',
    ),
    GrowthMetric(
      label: '+10% More Active',
      improvementPercent: 10,
      subtitle: 'Active minutes rose to 45 mins/day',
      category: 'activity',
    ),
  ];
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
  return const [
    HealthMilestone(
      id: 'm1',
      title: 'First Quest Completed',
      subtitle: 'Began the health journey',
      emoji: '🌱',
      completed: true,
      date: '10 May 2026',
    ),
    HealthMilestone(
      id: 'm2',
      title: 'Reached Tree Level 5',
      subtitle: 'Canopy is growing strong',
      emoji: '🌳',
      completed: true,
      date: '20 May 2026',
    ),
    HealthMilestone(
      id: 'm3',
      title: 'Earned 10 Achievements',
      subtitle: 'Unlocked milestones of consistency',
      emoji: '🏆',
      completed: true,
      date: '28 May 2026',
    ),
    HealthMilestone(
      id: 'm4',
      title: 'Reached 30 Day Streak',
      subtitle: 'Consistent daily garden care',
      emoji: '🔥',
      completed: false, // interactive - user can see progress or click
      date: 'Locked',
    ),
  ];
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
  return const [
    HealthGoal(
      id: 'g1',
      title: '3 More Quests',
      progress: 7,
      target: 10,
      reward: 'Level Up',
    ),
    HealthGoal(
      id: 'g2',
      title: '5 More Days Sleep Consistency',
      progress: 2,
      target: 7,
      reward: 'New Badge',
    ),
    HealthGoal(
      id: 'g3',
      title: '200 XP Earned',
      progress: 50,
      target: 200,
      reward: 'New Reward',
    ),
  ];
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
    return SmartInsight(
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
  final avgScore = (reports.fold<int>(0, (s, r) => s + r.score) / reports.length).round();

  // Top category
  final avgSleep = reports.fold<int>(0, (s, r) => s + r.sleep) ~/ reports.length;
  final avgQuest = reports.fold<int>(0, (s, r) => s + r.quest) ~/ reports.length;
  final avgMood = reports.fold<int>(0, (s, r) => s + r.mood) ~/ reports.length;
  final avgActivity = reports.fold<int>(0, (s, r) => s + r.activity) ~/ reports.length;

  final categoryScores = {
    'Tidur': avgSleep,
    'Quest': avgQuest,
    'Mood': avgMood,
    'Aktivitas': avgActivity,
  };
  final topCategory = categoryScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

  // Weekly trend (last 7 vs previous 7)
  final last7 = reports.length >= 7 ? reports.sublist(reports.length - 7) : reports;
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
    recommendation = 'Tidur kamu masih perlu ditingkatkan. Coba tidur lebih awal 30 menit malam ini!';
  } else if (score.quest < 15) {
    recommendation = 'Kamu hampir di puncak performa! Selesaikan 1 quest lagi hari ini.';
  } else if (score.mood < 15) {
    recommendation = 'Mood kamu bisa lebih baik. Coba 5 menit meditasi dengan alat relaksasi.';
  } else {
    recommendation = 'Performa kamu luar biasa! Pertahankan konsistensi untuk naik level. 🌟';
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

// Helper for generating report data
HealthDayReport _reportForDay(DateTime date, int currentScore, int index) {
  final wave = (index % 7) - 3;
  final score = index == 0 ? currentScore : (currentScore - wave * 3).clamp(20, 96);
  final sleep = (score * .24 + wave).round().clamp(3, 25);
  final quest = (score * .23 - wave).round().clamp(3, 25);
  final mood = (score * .25 + 2).round().clamp(3, 25);
  final activity = (score - sleep - quest - mood).clamp(3, 25);
  
  final hydration = (score * .9 + wave * 5).round().clamp(40, 100);
  final nutrition = (score * .85 - wave * 4).round().clamp(35, 100);

  return HealthDayReport(
    date: date,
    score: score,
    sleep: sleep,
    quest: quest,
    mood: mood,
    activity: activity,
    consistency: (score * .8).round().clamp(0, 100),
    hydration: hydration,
    nutrition: nutrition,
  );
}
