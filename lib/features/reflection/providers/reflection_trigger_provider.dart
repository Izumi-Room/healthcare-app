import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/reflection_entry.dart';
import '../../home/providers/health_score_provider.dart';

final reflectionTriggerProvider = Provider<bool>((ref) {
  final score = ref.watch(healthScoreProvider);
  return score.total >= 75 && score.goodStreakDays >= 3;
});

final reflectionPromptHandledProvider = StateProvider<bool>((ref) => false);

final reflectionProvider =
    StateNotifierProvider<ReflectionNotifier, List<ReflectionEntry>>((ref) {
  return ReflectionNotifier(ref)..load();
});

/// Counts consecutive days with at least one reflection entry
final reflectionStreakProvider = Provider<int>((ref) {
  final entries = ref.watch(reflectionProvider);
  if (entries.isEmpty) return 0;

  int streak = 0;
  var checkDate = DateTime.now();
  
  for (var i = 0; i < 365; i++) {
    final dayStart = DateTime(checkDate.year, checkDate.month, checkDate.day);
    final hasEntry = entries.any((e) {
      final entryDay = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      return entryDay == dayStart;
    });
    if (hasEntry) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      // Allow skipping today if no entry yet (only break on past gaps)
      if (i == 0) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }
      break;
    }
  }
  return streak;
});

class ReflectionNotifier extends StateNotifier<List<ReflectionEntry>> {
  ReflectionNotifier(this.ref) : super(const []);

  final Ref ref;
  static const _boxName = 'reflection_box';

  Future<void> load() async {
    final box = await Hive.openBox(_boxName);
    final stored = box.get('entries');
    if (stored is List) {
      state = stored
          .whereType<Map>()
          .map(ReflectionEntry.fromMap)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  /// Legacy method for simple question+answer entries
  Future<void> add(String question, String answer) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final existingIndex = state.indexWhere((e) {
      final entryDay = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      return entryDay == todayStart;
    });

    final score = ref.read(healthScoreProvider).total;
    final entry = ReflectionEntry(
      id: existingIndex != -1 
          ? state[existingIndex].id 
          : DateTime.now().microsecondsSinceEpoch.toString(),
      timestamp: existingIndex != -1 ? state[existingIndex].timestamp : DateTime.now(),
      question: question,
      answer: answer,
      scoreAtEntry: score,
    );

    if (existingIndex != -1) {
      final updatedList = List<ReflectionEntry>.from(state);
      updatedList[existingIndex] = entry;
      state = updatedList;
    } else {
      state = [entry, ...state];
    }
    
    // Sort just in case
    state = [...state]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final box = await Hive.openBox(_boxName);
    await box.put('entries', state.map((e) => e.toMap()).toList());
  }

  /// Full immersive flow entry
  Future<void> addFullReflection({
    required String mood,
    required List<String> emotions,
    required String question,
    required String answer,
    required String highlight,
    required List<String> gratitudes,
    required String tomorrowIntention,
    required String summary,
  }) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final existingIndex = state.indexWhere((e) {
      final entryDay = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      return entryDay == todayStart;
    });

    final score = ref.read(healthScoreProvider).total;
    final entry = ReflectionEntry(
      id: existingIndex != -1 
          ? state[existingIndex].id 
          : DateTime.now().microsecondsSinceEpoch.toString(),
      timestamp: existingIndex != -1 ? state[existingIndex].timestamp : DateTime.now(),
      question: question,
      answer: answer,
      scoreAtEntry: score,
      mood: mood,
      emotions: emotions,
      highlight: highlight,
      gratitudes: gratitudes,
      tomorrowIntention: tomorrowIntention,
      summary: summary,
    );

    if (existingIndex != -1) {
      final updatedList = List<ReflectionEntry>.from(state);
      updatedList[existingIndex] = entry;
      state = updatedList;
    } else {
      state = [entry, ...state];
      // Award XP only for creating a new reflection (+4 quest pts ≈ +100 XP)
      await ref.read(healthScoreProvider.notifier).addQuestPoints(4);
    }
    
    // Sort just in case
    state = [...state]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final box = await Hive.openBox(_boxName);
    await box.put('entries', state.map((e) => e.toMap()).toList());
  }
}

const reflectionQuestions = [
  'Apa momen terbaik di harimu?',
  'Apa yang kamu syukuri hari ini?',
  'Apa tantangan terbesarmu hari ini?',
  'Apa yang membuatmu tersenyum?',
  'Apa yang ingin kamu perbaiki besok?',
  'Kebiasaan tidur apa yang paling membantu akhir-akhir ini?',
  'Hal kecil apa yang membuat mood kamu lebih ringan?',
  'Aktivitas apa yang terasa paling memberi energi?',
  'Quest mana yang paling mudah kamu ulangi besok?',
  'Apa yang kamu hindari sehingga hari ini terasa lebih sehat?',
  'Siapa atau apa yang mendukung ritme baikmu?',
  'Jam berapa tubuhmu terasa paling segar?',
  'Apa tanda awal bahwa kamu sedang membaik?',
  'Makanan atau minuman apa yang membantu energimu stabil?',
  'Apa yang ingin kamu pertahankan selama seminggu ke depan?',
  'Bagian hari mana yang paling tenang?',
  'Apa yang kamu lakukan saat stres mulai naik?',
  'Lingkungan seperti apa yang membuatmu lebih fokus?',
  'Apa bentuk istirahat yang benar-benar terasa memulihkan?',
  'Kemenangan kecil apa yang patut kamu catat?',
];
