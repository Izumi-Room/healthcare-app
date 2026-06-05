import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/health_score.dart';

final healthScoreProvider =
    StateNotifierProvider<HealthScoreNotifier, HealthScore>((ref) {
  return HealthScoreNotifier()..load();
});

class HealthScoreNotifier extends StateNotifier<HealthScore> {
  HealthScoreNotifier() : super(HealthScore.initial());

  static const _boxName = 'health_score_box';
  static const _key = 'latest';

  Future<void> load() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_key);
    if (raw is Map) {
      state = HealthScore.fromMap(raw);
    }
  }

  Future<void> _save(HealthScore score) async {
    state = score;
    final box = await Hive.openBox(_boxName);
    await box.put(_key, score.toMap());
  }

  Future<void> updateSleep(int value) => _update(sleep: value);
  Future<void> updateQuest(int value) => _update(quest: value);
  Future<void> updateMood(int value) => _update(mood: value);
  Future<void> updateActivity(int value) => _update(activity: value);

  Future<void> addQuestPoints(int points) {
    return _update(quest: (state.quest + points).clamp(0, 25));
  }

  Future<void> demoAdjust(String key, int delta) {
    switch (key) {
      case 'sleep':
        return _update(sleep: (state.sleep + delta).clamp(0, 25));
      case 'quest':
        return _update(quest: (state.quest + delta).clamp(0, 25));
      case 'mood':
        return _update(mood: (state.mood + delta).clamp(0, 25));
      default:
        return _update(activity: (state.activity + delta).clamp(0, 25));
    }
  }

  Future<void> _update({
    int? sleep,
    int? quest,
    int? mood,
    int? activity,
  }) async {
    final next = state.copyWith(
      sleep: sleep?.clamp(0, 25),
      quest: quest?.clamp(0, 25),
      mood: mood?.clamp(0, 25),
      activity: activity?.clamp(0, 25),
      previousTotal: state.total,
      goodStreakDays: _nextGoodStreak(
        sleep ?? state.sleep,
        quest ?? state.quest,
        mood ?? state.mood,
        activity ?? state.activity,
      ),
      updatedAt: DateTime.now(),
    );
    await _save(next);
  }

  int _nextGoodStreak(int sleep, int quest, int mood, int activity) {
    final total = sleep + quest + mood + activity;
    if (total < 75) return 0;
    return (state.goodStreakDays + 1).clamp(1, 30);
  }
}
