import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/sleep_record.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/health_score_provider.dart';

final sleepProvider =
    StateNotifierProvider<SleepNotifier, List<SleepRecord>>((ref) {
  final uid = ref.watch(authProvider.select((state) => state.user?.uid));
  return SleepNotifier(ref, uid)..load();
});

class SleepNotifier extends StateNotifier<List<SleepRecord>> {
  SleepNotifier(this.ref, this.uid) : super(const []);

  final Ref ref;
  final String? uid;
  static const _boxName = 'sleep_box';

  String get _recordsKey => uid == null ? 'records_guest' : 'records_$uid';

  Future<void> load() async {
    final box = await Hive.openBox(_boxName);
    final stored = box.get(_recordsKey);
    if (stored is List && stored.isNotEmpty) {
      state = stored.whereType<Map>().map(SleepRecord.fromMap).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
  }

  Future<void> saveToday(TimeOfDay sleep, TimeOfDay wake) async {
    final now = DateTime.now();
    var sleepDate =
        DateTime(now.year, now.month, now.day, sleep.hour, sleep.minute);
    var wakeDate =
        DateTime(now.year, now.month, now.day, wake.hour, wake.minute);
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
    await box.put(_recordsKey, state.map((record) => record.toMap()).toList());
  }

  String patternStatus() {
    final recent = state.length <= 7 ? state : state.sublist(state.length - 7);
    if (recent.isEmpty) return 'Stable';
    final average =
        recent.fold<double>(0, (sum, item) => sum + item.durationHours) /
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
