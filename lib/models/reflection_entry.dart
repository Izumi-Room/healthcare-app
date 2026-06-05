class ReflectionEntry {
  const ReflectionEntry({
    required this.id,
    required this.timestamp,
    required this.question,
    required this.answer,
    required this.scoreAtEntry,
    this.mood = '',
    this.emotions = const [],
    this.highlight = '',
    this.gratitudes = const [],
    this.tomorrowIntention = '',
    this.summary = '',
  });

  final String id;
  final DateTime timestamp;
  final String question;
  final String answer;
  final int scoreAtEntry;

  // New immersive flow fields
  final String mood;
  final List<String> emotions;
  final String highlight;
  final List<String> gratitudes;
  final String tomorrowIntention;
  final String summary;

  /// Whether this entry was created via the new immersive flow
  bool get isFullReflection => mood.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'question': question,
      'answer': answer,
      'scoreAtEntry': scoreAtEntry,
      'mood': mood,
      'emotions': emotions,
      'highlight': highlight,
      'gratitudes': gratitudes,
      'tomorrowIntention': tomorrowIntention,
      'summary': summary,
    };
  }

  static ReflectionEntry fromMap(Map<dynamic, dynamic> map) {
    return ReflectionEntry(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
      scoreAtEntry: map['scoreAtEntry'] as int? ?? 0,
      mood: map['mood'] as String? ?? '',
      emotions: (map['emotions'] as List?)?.cast<String>() ?? const [],
      highlight: map['highlight'] as String? ?? '',
      gratitudes: (map['gratitudes'] as List?)?.cast<String>() ?? const [],
      tomorrowIntention: map['tomorrowIntention'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
    );
  }
}
