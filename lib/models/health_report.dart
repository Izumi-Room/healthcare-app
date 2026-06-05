import 'health_score.dart';

enum ReportPeriod { daily, weekly, monthly }

class HealthDayReport {
  const HealthDayReport({
    required this.date,
    required this.score,
    required this.sleep,
    required this.quest,
    required this.mood,
    required this.activity,
    required this.consistency,
    this.hydration = 75,
    this.nutrition = 70,
  });

  final DateTime date;
  final int score;
  final int sleep;
  final int quest;
  final int mood;
  final int activity;
  final int consistency;
  final int hydration;
  final int nutrition;

  HealthScore get healthScore => HealthScore(
        sleep: sleep,
        quest: quest,
        mood: mood,
        activity: activity,
      );
}

class TrendMetric {
  const TrendMetric(this.label, this.current, this.previous);

  final String label;
  final int current;
  final int previous;

  int get delta => current - previous;
}
