import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/daily_quest.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/health_score_provider.dart';

final questProvider = StateNotifierProvider<QuestNotifier, QuestState>((ref) {
  final uid = ref.watch(authProvider.select((state) => state.user?.uid));
  return QuestNotifier(ref, uid)..load();
});

class QuestState {
  const QuestState({
    required this.quests,
    required this.streak,
    required this.dateKey,
  });

  factory QuestState.initial() {
    final today = _dateKey(DateTime.now());
    return QuestState(quests: _pickDailyQuests(10), streak: 0, dateKey: today);
  }

  final List<DailyQuest> quests;
  final int streak;
  final String dateKey;

  bool get allCompleted => quests.every((quest) => quest.completed);

  QuestState copyWith({
    List<DailyQuest>? quests,
    int? streak,
    String? dateKey,
  }) {
    return QuestState(
      quests: quests ?? this.quests,
      streak: streak ?? this.streak,
      dateKey: dateKey ?? this.dateKey,
    );
  }
}

class QuestNotifier extends StateNotifier<QuestState> {
  QuestNotifier(this.ref, this.uid) : super(QuestState.initial());

  final Ref ref;
  final String? uid;
  static const _boxName = 'quest_box';

  String get _prefix => uid == null ? 'guest' : uid!;
  String get _dateKeyKey => 'dateKey_$_prefix';
  String get _streakKey => 'streak_$_prefix';
  String get _completedKey => 'completed_$_prefix';

  Future<void> load() async {
    final box = await Hive.openBox(_boxName);
    final today = _dateKey(DateTime.now());
    final storedDate = box.get(_dateKeyKey) as String?;
    final streak = box.get(_streakKey) as int? ?? 0;
    if (storedDate == today) {
      final completed =
          (box.get(_completedKey) as List?)?.cast<String>() ?? [];
      state = QuestState(
        quests: _pickDailyQuests(ref.read(healthScoreProvider).sleep)
            .map((quest) => quest.copyWith(completed: completed.contains(quest.id)))
            .toList(),
        streak: streak,
        dateKey: today,
      );
    } else {
      state = QuestState(
        quests: _pickDailyQuests(ref.read(healthScoreProvider).sleep),
        streak: streak,
        dateKey: today,
      );
      await _save();
    }
  }

  Future<void> complete(String id) async {
    final questIndex = state.quests.indexWhere((q) => q.id == id);
    if (questIndex == -1 || state.quests[questIndex].completed) {
      return;
    }
    final wasAllCompleted = state.allCompleted;
    final quests = [
      for (final quest in state.quests)
        quest.id == id ? quest.copyWith(completed: true) : quest,
    ];
    state = state.copyWith(quests: quests);
    await ref.read(healthScoreProvider.notifier).addQuestPoints(5);
    if (!wasAllCompleted && state.allCompleted) {
      state = state.copyWith(streak: state.streak + 1);
    }
    await _save();
  }

  Future<void> _save() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_dateKeyKey, state.dateKey);
    await box.put(_streakKey, state.streak);
    await box.put(
      _completedKey,
      state.quests
          .where((quest) => quest.completed)
          .map((quest) => quest.id)
          .toList(),
    );
  }
}

String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

List<DailyQuest> _pickDailyQuests(int sleepScore) {
  final bank = <DailyQuest>[
    for (var i = 0; i < 8; i++)
      DailyQuest(
        id: 'breath_$i',
        category: QuestCategory.breathing,
        title: 'Napas 4-7-8 selama ${3 + i % 4} menit',
        durationMinutes: 3 + i % 4,
      ),
    for (var i = 0; i < 8; i++)
      DailyQuest(
        id: 'gratitude_$i',
        category: QuestCategory.gratitude,
        title: 'Tulis ${3 + i % 3} hal baik hari ini',
        durationMinutes: 5,
      ),
    for (var i = 0; i < 8; i++)
      DailyQuest(
        id: 'walk_$i',
        category: QuestCategory.walking,
        title: 'Jalan santai ${8 + i * 2} menit',
        durationMinutes: 8 + i * 2,
      ),
    for (var i = 0; i < 8; i++)
      DailyQuest(
        id: 'stretch_$i',
        category: QuestCategory.stretching,
        title: 'Peregangan bahu dan punggung',
        durationMinutes: 5 + i % 5,
      ),
    for (var i = 0; i < 8; i++)
      DailyQuest(
        id: 'water_$i',
        category: QuestCategory.hydration,
        title: 'Minum air dan jeda layar',
        durationMinutes: 2 + i % 3,
      ),
    for (var i = 0; i < 8; i++)
      DailyQuest(
        id: 'journal_$i',
        category: QuestCategory.journaling,
        title: 'Jurnal singkat: apa yang terasa berat?',
        durationMinutes: 6 + i % 5,
      ),
    for (var i = 0; i < 8; i++)
      DailyQuest(
        id: 'meditate_$i',
        category: QuestCategory.meditation,
        title: 'Meditasi fokus tubuh',
        durationMinutes: sleepScore < 12 ? 4 : 8 + i % 6,
      ),
  ];

  final today = DateTime.now().day;
  final filtered = sleepScore < 12
      ? bank.where((quest) => quest.durationMinutes <= 10).toList()
      : bank;
  return [
    filtered[today % filtered.length],
    filtered[(today + 17) % filtered.length],
    filtered[(today + 35) % filtered.length],
  ];
}
