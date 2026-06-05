import 'dart:convert';

/// Model representing a User Profile in Firebase Realtime Database
class FirebaseUserProfile {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final int createdAt;
  final int lastLogin;
  final int level;
  final int xp;
  final int coins;
  final int streak;

  FirebaseUserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.createdAt,
    required this.lastLogin,
    required this.level,
    required this.xp,
    required this.coins,
    required this.streak,
  });

  FirebaseUserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    int? createdAt,
    int? lastLogin,
    int? level,
    int? xp,
    int? coins,
    int? streak,
  }) {
    return FirebaseUserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'level': level,
      'xp': xp,
      'coins': coins,
      'streak': streak,
    };
  }

  factory FirebaseUserProfile.fromMap(Map<dynamic, dynamic> map) {
    return FirebaseUserProfile(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      createdAt: map['createdAt'] as int? ?? 0,
      lastLogin: map['lastLogin'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      coins: map['coins'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory FirebaseUserProfile.fromJson(String source) =>
      FirebaseUserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}

/// Model representing Tree System state in Firebase
class FirebaseTreeState {
  final int treeLevel;
  final String treeStage;
  final double growthPercentage;
  final String lastGrowthDate;
  final String treeType;

  FirebaseTreeState({
    required this.treeLevel,
    required this.treeStage,
    required this.growthPercentage,
    required this.lastGrowthDate,
    required this.treeType,
  });

  FirebaseTreeState copyWith({
    int? treeLevel,
    String? treeStage,
    double? growthPercentage,
    String? lastGrowthDate,
    String? treeType,
  }) {
    return FirebaseTreeState(
      treeLevel: treeLevel ?? this.treeLevel,
      treeStage: treeStage ?? this.treeStage,
      growthPercentage: growthPercentage ?? this.growthPercentage,
      lastGrowthDate: lastGrowthDate ?? this.lastGrowthDate,
      treeType: treeType ?? this.treeType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'treeLevel': treeLevel,
      'treeStage': treeStage,
      'growthPercentage': growthPercentage,
      'lastGrowthDate': lastGrowthDate,
      'treeType': treeType,
    };
  }

  factory FirebaseTreeState.fromMap(Map<dynamic, dynamic> map) {
    return FirebaseTreeState(
      treeLevel: map['treeLevel'] as int? ?? 1,
      treeStage: map['treeStage'] as String? ?? 'Seed',
      growthPercentage: (map['growthPercentage'] as num?)?.toDouble() ?? 0.0,
      lastGrowthDate: map['lastGrowthDate'] as String? ?? '',
      treeType: map['treeType'] as String? ?? 'Oak',
    );
  }
}

/// Model representing a User Setting
class FirebaseSettings {
  final String theme;
  final bool notificationsEnabled;
  final String language;

  FirebaseSettings({
    required this.theme,
    required this.notificationsEnabled,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'language': language,
    };
  }

  factory FirebaseSettings.fromMap(Map<dynamic, dynamic> map) {
    return FirebaseSettings(
      theme: map['theme'] as String? ?? 'light',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      language: map['language'] as String? ?? 'en',
    );
  }
}

/// Model representing statistical dashboard info
class FirebaseStats {
  final int totalXP;
  final int totalReflections;
  final double totalSleepHours;
  final int completedQuests;
  final int longestStreak;
  final int treeGrowthDays;

  FirebaseStats({
    required this.totalXP,
    required this.totalReflections,
    required this.totalSleepHours,
    required this.completedQuests,
    required this.longestStreak,
    required this.treeGrowthDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalXP': totalXP,
      'totalReflections': totalReflections,
      'totalSleepHours': totalSleepHours,
      'completedQuests': completedQuests,
      'longestStreak': longestStreak,
      'treeGrowthDays': treeGrowthDays,
    };
  }

  factory FirebaseStats.fromMap(Map<dynamic, dynamic> map) {
    return FirebaseStats(
      totalXP: map['totalXP'] as int? ?? 0,
      totalReflections: map['totalReflections'] as int? ?? 0,
      totalSleepHours: (map['totalSleepHours'] as num?)?.toDouble() ?? 0.0,
      completedQuests: map['completedQuests'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      treeGrowthDays: map['treeGrowthDays'] as int? ?? 0,
    );
  }
}

/// Model representing Daily Quests in Firebase
class FirebaseDailyQuest {
  final String questId;
  final String title;
  final String description;
  final int rewardXP;
  final int rewardCoins;
  final bool completed;
  final int? completedAt;

  FirebaseDailyQuest({
    required this.questId,
    required this.title,
    required this.description,
    required this.rewardXP,
    required this.rewardCoins,
    required this.completed,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'questId': questId,
      'title': title,
      'description': description,
      'rewardXP': rewardXP,
      'rewardCoins': rewardCoins,
      'completed': completed,
      'completedAt': completedAt,
    };
  }

  factory FirebaseDailyQuest.fromMap(Map<dynamic, dynamic> map) {
    return FirebaseDailyQuest(
      questId: map['questId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      rewardXP: map['rewardXP'] as int? ?? 0,
      rewardCoins: map['rewardCoins'] as int? ?? 0,
      completed: map['completed'] as bool? ?? false,
      completedAt: map['completedAt'] as int?,
    );
  }
}

/// Model representing a single daily Reflection
class FirebaseReflection {
  final String date;
  final String mood;
  final List<String> emotions;
  final String journal;
  final List<String> gratitudeList;
  final String tomorrowGoal;

  FirebaseReflection({
    required this.date,
    required this.mood,
    required this.emotions,
    required this.journal,
    required this.gratitudeList,
    required this.tomorrowGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'mood': mood,
      'emotions': emotions,
      'journal': journal,
      'gratitudeList': gratitudeList,
      'tomorrowGoal': tomorrowGoal,
    };
  }

  factory FirebaseReflection.fromMap(Map<dynamic, dynamic> map) {
    return FirebaseReflection(
      date: map['date'] as String? ?? '',
      mood: map['mood'] as String? ?? '',
      emotions: (map['emotions'] as List?)?.cast<String>() ?? const [],
      journal: map['journal'] as String? ?? '',
      gratitudeList: (map['gratitudeList'] as List?)?.cast<String>() ?? const [],
      tomorrowGoal: map['tomorrowGoal'] as String? ?? '',
    );
  }
}

/// Model representing Sleep Record in Firebase
class FirebaseSleepRecord {
  final int sleepTime;
  final int wakeTime;
  final double duration;
  final int qualityScore;
  final String sleepDate;

  FirebaseSleepRecord({
    required this.sleepTime,
    required this.wakeTime,
    required this.duration,
    required this.qualityScore,
    required this.sleepDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'sleepTime': sleepTime,
      'wakeTime': wakeTime,
      'duration': duration,
      'qualityScore': qualityScore,
      'sleepDate': sleepDate,
    };
  }

  factory FirebaseSleepRecord.fromMap(Map<dynamic, dynamic> map) {
    return FirebaseSleepRecord(
      sleepTime: map['sleepTime'] as int? ?? 0,
      wakeTime: map['wakeTime'] as int? ?? 0,
      duration: (map['duration'] as num?)?.toDouble() ?? 0.0,
      qualityScore: map['qualityScore'] as int? ?? 0,
      sleepDate: map['sleepDate'] as String? ?? '',
    );
  }
}

/// Model representing Achievements in Firebase
class FirebaseAchievement {
  final String achievementId;
  final String title;
  final String description;
  final bool unlocked;
  final int? unlockedAt;

  FirebaseAchievement({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.unlocked,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'title': title,
      'description': description,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt,
    };
  }

  factory FirebaseAchievement.fromMap(Map<dynamic, dynamic> map) {
    return FirebaseAchievement(
      achievementId: map['achievementId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      unlocked: map['unlocked'] as bool? ?? false,
      unlockedAt: map['unlockedAt'] as int?,
    );
  }
}
