# Firebase Realtime Database Optimization & Production Guide

This document describes indexing recommendations, cost control strategies, read/write optimization techniques, and the offline synchronization strategy for the **VitaTree** self-improvement app.

---

## 1. Indexing Recommendations (`.indexOn`)

Firebase Realtime Database indexing is crucial for querying children efficiently without downloading all data to the client to filter locally. If you run a query using `.orderByChild()` without an index, Firebase returns a warning, and performance degrades severely with large datasets.

Since our database layout is flat and keyed directly by user `uid` (e.g., `/reflections/uid_123/2026-06-05`), primary lookups occur directly by path, which does not require indices. However, if you perform queries across records, define indices as follows:

```json
{
  "rules": {
    "reflections": {
      "$uid": {
        ".indexOn": ["date", "mood"]
      }
    },
    "sleep": {
      "$uid": {
        ".indexOn": ["sleepDate", "qualityScore"]
      }
    },
    "quests": {
      "$uid": {
        ".indexOn": ["completed", "completedAt"]
      }
    }
  }
}
```

- **Use Cases**:
  - `reflections/$uid`: Querying the most recent reflections or filtering by mood.
  - `sleep/$uid`: Finding sleep records within a specific date range or filtering poor sleep scores to suggest tips.
  - `quests/$uid`: Querying uncompleted daily quests.

---

## 2. Firebase Cost Optimization & Read/Write Reductions

Firebase Realtime Database pricing is determined by:
1. **Stored Data volume** ($0.25 per GB/month).
2. **Downloaded Data volume / Bandwidth** ($1.00 per GB downloaded).

### Optimization Rules:
* **Never Nest Large Lists**: Reading `/users/uid` will download profile, tree, stats, and settings, but it will *not* download sleep, reflections, achievements, or quests. This saves immense bandwidth.
* **Keep Keys Short**: Key names are downloaded with every single node. For example, instead of naming a field `reflectionStreakLongestInDays`, use `longestStreak`.
* **Use Listeners Selectively**:
  - Use `once()` (single reads) for static views, dashboards, and historical journals.
  - Use `onValue` (realtime listeners) *only* for elements that actually change in real time on the current screen (e.g., user profiles or streaks when doing a quest).
  - Unsubscribe from listeners (`cancel()`) as soon as widgets are disposed to prevent ghost background listeners downloading data.

---

## 3. Read Optimization Techniques
* **Shallow Queries**: If you only need to know if a user has entries under a path without downloading them, write a shallow query or read a dedicated summary stat instead.
* **Query Limits**: When pulling logs (e.g., sleep history or reflection journal), always append `.limitToLast(30)` or `.limitToFirst(30)` to fetch in small paginated chunks.
* **Data Denoising**: Store dates as simple `yyyy-MM-dd` keys (like `/reflections/uid/2026-06-05`) instead of push IDs (`-O1Jabcde...`). Date keys allow O(1) random access reads directly for today's status.

---

## 4. Write Optimization Techniques
* **Atomic Multi-Path Updates**:
  When a user completes a quest, you must update the quest completion state, add XP/Level to the profile, and update stats. Instead of running 3 separate write operations (which increases network overhead and risk of partial failure), execute an atomic update:
  ```dart
  final updates = {
    'quests/$uid/$questId/completed': true,
    'quests/$uid/$questId/completedAt': ServerValue.timestamp,
    'users/$uid/profile/xp': newXp,
    'users/$uid/profile/coins': newCoins,
    'users/$uid/stats/completedQuests': newCount,
  };
  await databaseRef.update(updates);
  ```
* **Debouncing Syncs**: For stats or settings that change rapidly, update local state immediately and debounce the write to Firebase (e.g., wait 2 seconds after user stops dragging a slider or checking tasks).

---

## 5. Offline Support Strategy

Mobile networks are unstable. VitaTree is a personal health companion that must work seamlessly offline (on planes, subways, or remote areas).

### Flutter Configuration:
```dart
// Enable disk persistence at app startup
FirebaseDatabase.instance.setPersistenceEnabled(true);
FirebaseDatabase.instance.setPersistenceCacheSizeBytes(100 * 1024 * 1024); // 100MB cache
```

### Synchronization Flow:
1. **Disk Caching**: All writes are cached locally on disk instantly and synced to the cloud when a connection is restored.
2. **KeepSynced**: For core elements like the user's current tree growth state and streak profile, mark them to keep synced:
   ```dart
   final profileRef = FirebaseDatabase.instance.ref('users/$uid/profile');
   profileRef.keepSynced(true);
   ```
   This tells Firebase to maintain a local sync copy of this sub-tree on disk, keeping it fresh even when the app is running in the background.
3. **Transaction Operations**: When updating items that rely on current state (e.g., increments like level-ups or streaks), use `.runTransaction()` rather than `.set()` to prevent local concurrent updates from overwriting remote cloud changes.
