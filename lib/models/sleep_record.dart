class SleepRecord {
  const SleepRecord({
    required this.date,
    required this.sleepTime,
    required this.wakeTime,
    required this.durationHours,
    required this.score,
  });

  final DateTime date;
  final DateTime sleepTime;
  final DateTime wakeTime;
  final double durationHours;
  final int score;

  String get quality {
    if (score >= 80) return 'Ideal';
    if (score >= 50) return 'Cukup';
    return 'Buruk';
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'sleepTime': sleepTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'durationHours': durationHours,
      'score': score,
    };
  }

  static SleepRecord fromMap(Map<dynamic, dynamic> map) {
    return SleepRecord(
      date: DateTime.parse(map['date'] as String),
      sleepTime: DateTime.parse(map['sleepTime'] as String),
      wakeTime: DateTime.parse(map['wakeTime'] as String),
      durationHours: (map['durationHours'] as num).toDouble(),
      score: map['score'] as int,
    );
  }
}

int calculateSleepScore(double hours) {
  if (hours < 5 || hours > 10) return 20;
  if ((hours >= 5 && hours < 7) || (hours > 9 && hours <= 10)) return 60;
  return 100;
}
