import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/firebase_models.dart';

/// Custom database exception class to handle error translation in production.
class FirebaseDatabaseException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;

  FirebaseDatabaseException({
    required this.message,
    required this.code,
    this.originalError,
  });

  @override
  String toString() => 'FirebaseDatabaseException: [$code] $message';
}

/// A complete, production-ready Firebase Realtime Database Service.
/// Supports offline synchronization, atomic operations, transactions, and robust error handling.
class FirebaseDatabaseService {
  FirebaseDatabaseService._internal();

  static final FirebaseDatabaseService instance = FirebaseDatabaseService._internal();

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  /// Initialize Firebase Realtime Database configurations such as offline persistence and cache limits.
  /// Call this method during application initialization (e.g., in main.dart).
  Future<void> initialize() async {
    try {
      _db.setPersistenceEnabled(true);
      // Set cache size limit to 100MB
      _db.setPersistenceCacheSizeBytes(100 * 1024 * 1024);
    } catch (e) {
      // Persistence can only be configured before any other database interaction
      // Catching errors to prevent crashes in hot restarts
      debugPrint('FirebaseDatabaseService initialization warning: $e');
    }
  }

  // ==========================================
  // DATABASE REFERENCE PATH GENERATORS
  // ==========================================

  DatabaseReference _profileRef(String uid) => _db.ref('users/$uid/profile');
  DatabaseReference _treeRef(String uid) => _db.ref('users/$uid/tree');
  DatabaseReference _settingsRef(String uid) => _db.ref('users/$uid/settings');
  DatabaseReference _statsRef(String uid) => _db.ref('users/$uid/stats');
  DatabaseReference _questsRef(String uid) => _db.ref('quests/$uid');
  DatabaseReference _reflectionsRef(String uid) => _db.ref('reflections/$uid');
  DatabaseReference _sleepRef(String uid) => _db.ref('sleep/$uid');
  DatabaseReference _achievementsRef(String uid) => _db.ref('achievements/$uid');

  // ==========================================
  // USER PROFILE CRUD
  // ==========================================

  /// Setup the user profile node upon registration.
  Future<void> createUserProfile(FirebaseUserProfile profile) async {
    return _runWithHandler(() async {
      await _profileRef(profile.uid).set(profile.toMap());
      // Initialize stats node
      await _statsRef(profile.uid).set(FirebaseStats(
        totalXP: 0,
        totalReflections: 0,
        totalSleepHours: 0.0,
        completedQuests: 0,
        longestStreak: 0,
        treeGrowthDays: 0,
      ).toMap());
    }, 'create_profile');
  }

  /// Get user profile info.
  Future<FirebaseUserProfile> getUserProfile(String uid) async {
    return _runWithHandler(() async {
      final snapshot = await _profileRef(uid).get();
      if (!snapshot.exists) {
        throw FirebaseDatabaseException(
          message: 'User profile not found.',
          code: 'profile_not_found',
        );
      }
      return FirebaseUserProfile.fromMap(snapshot.value as Map);
    }, 'get_profile');
  }

  /// Stream of user profile for real-time reactivity (UI sync).
  Stream<FirebaseUserProfile> streamUserProfile(String uid) {
    // Keep user profile synchronized offline automatically
    _profileRef(uid).keepSynced(true);
    return _profileRef(uid).onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) {
        throw FirebaseDatabaseException(
          message: 'User profile node is empty.',
          code: 'profile_empty',
        );
      }
      return FirebaseUserProfile.fromMap(val as Map);
    });
  }

  /// Perform transactional XP and Coins increment.
  /// Prevents race conditions when user earns rewards simultaneously on multiple threads.
  Future<void> rewardUserReward(String uid, {required int xpGained, required int coinsGained}) async {
    return _runWithHandler(() async {
      final profileRef = _profileRef(uid);
      await profileRef.runTransaction((Object? currentData) {
        if (currentData == null) {
          return Transaction.success(null);
        }

        final Map<dynamic, dynamic> profile = Map<dynamic, dynamic>.from(currentData as Map);
        final currentXp = profile['xp'] as int? ?? 0;
        final currentCoins = profile['coins'] as int? ?? 0;
        final currentLevel = profile['level'] as int? ?? 1;

        int newXp = currentXp + xpGained;
        int newCoins = currentCoins + coinsGained;
        int newLevel = currentLevel;

        // Level Up Threshold: Level * 500 XP
        int xpThreshold = newLevel * 500;
        while (newXp >= xpThreshold) {
          newXp -= xpThreshold;
          newLevel += 1;
          xpThreshold = newLevel * 500;
        }

        profile['xp'] = newXp;
        profile['coins'] = newCoins;
        profile['level'] = newLevel;

        return Transaction.success(profile);
      });
    }, 'reward_user');
  }

  // ==========================================
  // TREE SYSTEM CRUD
  // ==========================================

  /// Initialize or update the Tree system state.
  Future<void> updateTreeState(String uid, FirebaseTreeState treeState) async {
    return _runWithHandler(() async {
      await _treeRef(uid).set(treeState.toMap());
    }, 'update_tree');
  }

  /// Get the current growth state of the user's tree.
  Future<FirebaseTreeState?> getTreeState(String uid) async {
    return _runWithHandler(() async {
      final snapshot = await _treeRef(uid).get();
      if (!snapshot.exists) return null;
      return FirebaseTreeState.fromMap(snapshot.value as Map);
    }, 'get_tree');
  }

  // ==========================================
  // SETTINGS CRUD
  // ==========================================

  /// Update user settings configurations.
  Future<void> updateSettings(String uid, FirebaseSettings settings) async {
    return _runWithHandler(() async {
      await _settingsRef(uid).set(settings.toMap());
    }, 'update_settings');
  }

  /// Get or stream user settings.
  Stream<FirebaseSettings> streamSettings(String uid) {
    _settingsRef(uid).keepSynced(true);
    return _settingsRef(uid).onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) {
        return FirebaseSettings(theme: 'light', notificationsEnabled: true, language: 'en');
      }
      return FirebaseSettings.fromMap(val as Map);
    });
  }

  // ==========================================
  // DAILY QUESTS CRUD
  // ==========================================

  /// Save daily quests for a user.
  Future<void> saveDailyQuests(String uid, List<FirebaseDailyQuest> quests) async {
    return _runWithHandler(() async {
      final Map<String, Map<String, dynamic>> updates = {};
      for (var quest in quests) {
        updates[quest.questId] = quest.toMap();
      }
      await _questsRef(uid).set(updates);
    }, 'save_quests');
  }

  /// Complete a quest and issue rewards atomically via multi-path updates.
  Future<void> completeDailyQuest(String uid, String questId, {required int xpReward, required int coinsReward}) async {
    return _runWithHandler(() async {
      final questRef = _questsRef(uid).child(questId);
      final questSnap = await questRef.get();
      if (!questSnap.exists) {
        throw FirebaseDatabaseException(
          message: 'Quest not found.',
          code: 'quest_not_found',
        );
      }

      final questData = Map<dynamic, dynamic>.from(questSnap.value as Map);
      if (questData['completed'] as bool? ?? false) {
        // Quest already completed
        return;
      }

      // Execute reward increments transactional first to calculate correct levelups
      await rewardUserReward(uid, xpGained: xpReward, coinsGained: coinsReward);

      // Perform multi-path atomic updates
      final Map<String, Object?> updates = {
        'quests/$uid/$questId/completed': true,
        'quests/$uid/$questId/completedAt': ServerValue.timestamp,
        'users/$uid/stats/completedQuests': ServerValue.increment(1),
        'users/$uid/stats/totalXP': ServerValue.increment(xpReward),
      };

      await _db.ref().update(updates);
    }, 'complete_quest');
  }

  /// Listen to user's daily quests.
  Stream<List<FirebaseDailyQuest>> streamDailyQuests(String uid) {
    return _questsRef(uid).onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return const [];
      final map = val as Map;
      return map.values.map((v) => FirebaseDailyQuest.fromMap(v as Map)).toList();
    });
  }

  // ==========================================
  // REFLECTION JOURNAL CRUD
  // ==========================================

  /// Save a user reflection. Overwrites if a reflection for that day already exists.
  Future<void> saveReflection(String uid, FirebaseReflection reflection) async {
    return _runWithHandler(() async {
      final dateKey = reflection.date; // Format yyyy-MM-dd
      final reflectionRef = _reflectionsRef(uid).child(dateKey);
      final refSnap = await reflectionRef.get();
      final isNewReflection = !refSnap.exists;

      // Clean check to match database rules validation criteria
      if (reflection.mood.isEmpty || reflection.journal.isEmpty) {
        throw FirebaseDatabaseException(
          message: 'Invalid reflection: mood and journal entries are required.',
          code: 'validation_error',
        );
      }

      // Atomic batch update
      final Map<String, Object?> updates = {
        'reflections/$uid/$dateKey': reflection.toMap(),
      };

      if (isNewReflection) {
        updates['users/$uid/stats/totalReflections'] = ServerValue.increment(1);
      }

      await _db.ref().update(updates);
    }, 'save_reflection');
  }

  /// Get reflection history (paginated chunk of last 30 logs).
  Future<List<FirebaseReflection>> getReflectionHistory(String uid, {int limit = 30}) async {
    return _runWithHandler(() async {
      final snapshot = await _reflectionsRef(uid)
          .orderByKey()
          .limitToLast(limit)
          .get();

      if (!snapshot.exists) return const [];
      final map = snapshot.value as Map;
      return map.values.map((v) => FirebaseReflection.fromMap(v as Map)).toList().reversed.toList();
    }, 'get_reflections');
  }

  // ==========================================
  // SLEEP TRACKING CRUD
  // ==========================================

  /// Log a sleep record.
  Future<void> logSleepRecord(String uid, FirebaseSleepRecord record) async {
    return _runWithHandler(() async {
      final dateKey = record.sleepDate; // Format yyyy-MM-dd
      final recordRef = _sleepRef(uid).child(dateKey);
      final recordSnap = await recordRef.get();
      final isNewSleep = !recordSnap.exists;

      // Validate hours bounds
      if (record.duration < 0 || record.duration > 24) {
        throw FirebaseDatabaseException(
          message: 'Invalid sleep duration: must be between 0 and 24 hours.',
          code: 'validation_error',
        );
      }

      final Map<String, Object?> updates = {
        'sleep/$uid/$dateKey': record.toMap(),
      };

      if (isNewSleep) {
        updates['users/$uid/stats/totalSleepHours'] = ServerValue.increment(record.duration);
      }

      await _db.ref().update(updates);
    }, 'log_sleep');
  }

  /// Fetch sleep history records (paginated).
  Future<List<FirebaseSleepRecord>> getSleepHistory(String uid, {int limit = 30}) async {
    return _runWithHandler(() async {
      final snapshot = await _sleepRef(uid)
          .orderByKey()
          .limitToLast(limit)
          .get();

      if (!snapshot.exists) return const [];
      final map = snapshot.value as Map;
      return map.values.map((v) => FirebaseSleepRecord.fromMap(v as Map)).toList().reversed.toList();
    }, 'get_sleep');
  }

  // ==========================================
  // ACHIEVEMENTS CRUD
  // ==========================================

  /// Get all user achievements (read-only from database rules).
  Future<List<FirebaseAchievement>> getAchievements(String uid) async {
    return _runWithHandler(() async {
      final snapshot = await _achievementsRef(uid).get();
      if (!snapshot.exists) return const [];
      final map = snapshot.value as Map;
      return map.values.map((v) => FirebaseAchievement.fromMap(v as Map)).toList();
    }, 'get_achievements');
  }

  // ==========================================
  // DASHBOARD STATISTICS
  // ==========================================

  /// Listen to general user dashboard stats in realtime.
  Stream<FirebaseStats> streamUserStats(String uid) {
    _statsRef(uid).keepSynced(true);
    return _statsRef(uid).onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) {
        return FirebaseStats(
          totalXP: 0,
          totalReflections: 0,
          totalSleepHours: 0.0,
          completedQuests: 0,
          longestStreak: 0,
          treeGrowthDays: 0,
        );
      }
      return FirebaseStats.fromMap(val as Map);
    });
  }

  // ==========================================
  // PRIVATE HELPER EXCEPTION HANDLER
  // ==========================================

  /// Runs database actions and translates raw Firebase exceptions into clean user-facing ones.
  Future<T> _runWithHandler<T>(Future<T> Function() action, String operationContext) async {
    try {
      return await action();
    } catch (e) {
      if (e is FirebaseDatabaseException) {
        rethrow;
      }

      String code = 'unknown_error';
      String msg = 'An unexpected database error occurred during $operationContext.';

      // Defensive checking for FirebaseException properties across platforms (including Web JS interop)
      try {
        if (e is FirebaseException) {
          code = e.code.toLowerCase();
        } else {
          final dynamic dyn = e;
          if (dyn.code != null) {
            code = dyn.code.toString().toLowerCase();
          }
        }
      } catch (_) {}

      // Fallback: parse from string representation
      if (code == 'unknown_error') {
        final str = e.toString().toLowerCase();
        if (str.contains('permission-denied') || str.contains('permission_denied') || str.contains('403')) {
          code = 'permission_denied';
        } else if (str.contains('unavailable') || str.contains('network-error') || str.contains('network_error') || str.contains('500')) {
          code = 'network_unavailable';
        }
      }

      if (code.contains('permission-denied') || code.contains('permission_denied')) {
        msg = 'Permission denied. You do not have authorization to access this database path.';
        code = 'permission_denied';
      } else if (code.contains('unavailable') || code.contains('network-error') || code.contains('network_error')) {
        msg = 'Database server is currently offline or connection is lost. Operation will synchronize once connection is restored.';
        code = 'network_unavailable';
      }

      throw FirebaseDatabaseException(
        message: msg,
        code: code,
        originalError: e,
      );
    }
  }
}
