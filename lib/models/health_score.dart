enum TreeLevel {
  seed(1, 'Seed', 0, 10),
  sprout(2, 'Sprout', 11, 20),
  sapling(3, 'Sapling', 21, 35),
  youngTree(4, 'Young tree', 36, 50),
  grownTree(5, 'Grown tree', 51, 60),
  firstBloom(6, 'First bloom', 61, 68),
  developingBloom(7, 'Developing', 69, 74),
  fullBloom(8, 'Full bloom', 75, 82),
  radiant(9, 'Radiant', 83, 91),
  magical(10, 'Magical', 92, 100);

  const TreeLevel(this.level, this.label, this.minScore, this.maxScore);

  final int level;
  final String label;
  final int minScore;
  final int maxScore;

  String get assetPath => 'assets/trees/tree_lv$level.png';
  bool get blooms => level >= 6;
  bool get glows => level >= 9;

  static TreeLevel fromScore(int score) {
    final normalized = score.clamp(0, 100);
    return TreeLevel.values.firstWhere(
      (level) => normalized >= level.minScore && normalized <= level.maxScore,
      orElse: () => TreeLevel.magical,
    );
  }
}

class HealthScore {
  HealthScore({
    required this.sleep,
    required this.quest,
    required this.mood,
    required this.activity,
    this.previousTotal = 0,
    this.goodStreakDays = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory HealthScore.initial() {
    return HealthScore(
      sleep: 0,
      quest: 0,
      mood: 0,
      activity: 0,
      previousTotal: 0,
      goodStreakDays: 0,
      updatedAt: DateTime.now(),
    );
  }

  final int sleep;
  final int quest;
  final int mood;
  final int activity;
  final int previousTotal;
  final int goodStreakDays;
  final DateTime updatedAt;

  int get total => (sleep + quest + mood + activity).clamp(0, 100);
  TreeLevel get treeLevel => TreeLevel.fromScore(total);
  bool get isWilted => total < 30;
  bool get increased => total > previousTotal;
  bool get decreased => total < previousTotal;
  double get nextLevelProgress {
    final level = treeLevel;
    final span = (level.maxScore - level.minScore + 1).toDouble();
    return ((total - level.minScore + 1) / span).clamp(0.0, 1.0);
  }

  HealthScore copyWith({
    int? sleep,
    int? quest,
    int? mood,
    int? activity,
    int? previousTotal,
    int? goodStreakDays,
    DateTime? updatedAt,
  }) {
    return HealthScore(
      sleep: sleep ?? this.sleep,
      quest: quest ?? this.quest,
      mood: mood ?? this.mood,
      activity: activity ?? this.activity,
      previousTotal: previousTotal ?? this.previousTotal,
      goodStreakDays: goodStreakDays ?? this.goodStreakDays,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sleep': sleep,
      'quest': quest,
      'mood': mood,
      'activity': activity,
      'previousTotal': previousTotal,
      'goodStreakDays': goodStreakDays,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static HealthScore fromMap(Map<dynamic, dynamic> map) {
    return HealthScore(
      sleep: map['sleep'] as int? ?? 0,
      quest: map['quest'] as int? ?? 0,
      mood: map['mood'] as int? ?? 0,
      activity: map['activity'] as int? ?? 0,
      previousTotal: map['previousTotal'] as int? ?? 0,
      goodStreakDays: map['goodStreakDays'] as int? ?? 0,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
