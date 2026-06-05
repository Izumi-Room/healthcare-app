import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/sleep_record.dart';
import '../../home/providers/health_score_provider.dart';

final sleepProvider =
    StateNotifierProvider<SleepNotifier, List<SleepRecord>>((ref) {
  return SleepNotifier(ref)..load();
});

class SleepNotifier extends StateNotifier<List<SleepRecord>> {
  SleepNotifier(this.ref) : super(_seedRecords());

  final Ref ref;
  static const _boxName = 'sleep_box';

  Future<void> load() async {
    final box = await Hive.openBox(_boxName);
    final stored = box.get('records');
    if (stored is List && stored.isNotEmpty) {
      state = stored
          .whereType<Map>()
          .map(SleepRecord.fromMap)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
  }

  Future<void> saveToday(TimeOfDay sleep, TimeOfDay wake) async {
    final now = DateTime.now();
    var sleepDate = DateTime(now.year, now.month, now.day, sleep.hour, sleep.minute);
    var wakeDate = DateTime(now.year, now.month, now.day, wake.hour, wake.minute);
    if (!wakeDate.isAfter(sleepDate)) {
      wakeDate = wakeDate.add(const Duration(days: 1));
    }
    final hours = wakeDate.difference(sleepDate).inMinutes / 60.0;
    final score = calculateSleepScore(hours);
    final record = SleepRecord(
      date: DateTime(now.year, now.month, now.day),
      sleepTime: sleepDate,
      wakeTime: wakeDate,
      durationHours: hours,
      score: score,
    );
    final next = [
      ...state.where((item) => !_sameDay(item.date, record.date)),
      record,
    ]..sort((a, b) => a.date.compareTo(b.date));
    state = next.length > 30 ? next.sublist(next.length - 30) : next;
    await ref.read(healthScoreProvider.notifier).updateSleep(score ~/ 4);
    final box = await Hive.openBox(_boxName);
    await box.put('records', state.map((record) => record.toMap()).toList());
  }

  String patternStatus() {
    final recent = state.length <= 7 ? state : state.sublist(state.length - 7);
    if (recent.isEmpty) return 'Stable';
    final average = recent.fold<double>(0, (sum, item) => sum + item.durationHours) /
        recent.length;
    final spread = recent
        .map((item) => (item.durationHours - average).abs())
        .fold<double>(0, (max, value) => value > max ? value : max);
    if (average < 6) return 'Insufficient';
    if (average > 9.5) return 'Excessive';
    if (spread > 1.5) return 'Irregular';
    return 'Stable';
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<SleepRecord> _seedRecords() {
  final now = DateTime.now();
  final hours = [6.5, 7.2, 8.0, 5.5, 7.7, 8.4, 7.9];
  return [
    for (var i = 0; i < hours.length; i++)
      SleepRecord(
        date: DateTime(now.year, now.month, now.day - (hours.length - i - 1)),
        sleepTime: now.subtract(Duration(days: hours.length - i, hours: 8)),
        wakeTime: now.subtract(Duration(days: hours.length - i, minutes: 30)),
        durationHours: hours[i],
        score: calculateSleepScore(hours[i]),
      ),
  ];
}
