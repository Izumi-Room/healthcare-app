enum QuestCategory {
  meditation,
  journaling,
  walking,
  hydration,
  stretching,
  breathing,
  gratitude,
}

class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.category,
    required this.title,
    required this.durationMinutes,
    this.completed = false,
  });

  final String id;
  final QuestCategory category;
  final String title;
  final int durationMinutes;
  final bool completed;

  DailyQuest copyWith({bool? completed}) {
    return DailyQuest(
      id: id,
      category: category,
      title: title,
      durationMinutes: durationMinutes,
      completed: completed ?? this.completed,
    );
  }
}
