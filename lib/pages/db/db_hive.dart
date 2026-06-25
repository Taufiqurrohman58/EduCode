import 'package:hive/hive.dart';

class DBHive {
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox('gameProgress');

    /// GAME
    if (!_box.containsKey('unlockedLevel')) {
      await _box.put('unlockedLevel', 1);
    }

    if (!_box.containsKey('completedLevels')) {
      await _box.put('completedLevels', []);
    }

    /// MATERI
    if (!_box.containsKey('completedMateri')) {
      await _box.put('completedMateri', []);
    }
  }

  // =====================================================
  // GAME
  // =====================================================

  static int getUnlockedLevel() {
    return _box.get(
      'unlockedLevel',
      defaultValue: 1,
    );
  }

  static Future<void> unlockNextLevel(
    int currentLevel,
  ) async {
    int nextLevel = currentLevel + 1;

    if (nextLevel > getUnlockedLevel()) {
      await _box.put(
        'unlockedLevel',
        nextLevel,
      );
    }

    List completed = _box.get(
      'completedLevels',
      defaultValue: [],
    );

    if (!completed.contains(currentLevel)) {
      completed.add(currentLevel);

      await _box.put(
        'completedLevels',
        completed,
      );
    }
  }

  static bool isLevelCompleted(int level) {
    List completed = _box.get(
      'completedLevels',
      defaultValue: [],
    );

    return completed.contains(level);
  }

  // =====================================================
  // PROGRESS GAME
  // =====================================================

  static int getKonsepProgress(
    int konsepIndex,
  ) {
    int start = konsepIndex * 5 + 1;
    int end = start + 4;

    int total = 0;

    for (int i = start; i <= end; i++) {
      if (isLevelCompleted(i)) {
        total++;
      }
    }

    return total;
  }

  // =====================================================
  // BINTANG
  // =====================================================

  static int getKonsepBintang(
    int konsepIndex,
  ) {
    return getKonsepProgress(konsepIndex) * 3;
  }

  // =====================================================
  // LOCK KONSEP GAME
  // =====================================================

  static bool isKonsepUnlocked(
    int konsepIndex,
  ) {
    if (konsepIndex == 0) return true;

    int previousKonsep = konsepIndex - 1;

    return getKonsepProgress(
          previousKonsep,
        ) >=
        5;
  }

  // =====================================================
  // MATERI
  // =====================================================

  static Future<void> completeMateri(
    int materiIndex,
  ) async {
    List completed = _box.get(
      'completedMateri',
      defaultValue: [],
    );

    if (!completed.contains(materiIndex)) {
      completed.add(materiIndex);

      await _box.put(
        'completedMateri',
        completed,
      );
    }
  }

  static bool isMateriCompleted(
    int materiIndex,
  ) {
    List completed = _box.get(
      'completedMateri',
      defaultValue: [],
    );

    return completed.contains(materiIndex);
  }

  // =====================================================
  // PROGRESS MATERI
  // =====================================================

  static int getMateriProgress(
    int konsepIndex,
  ) {
    int start = konsepIndex * 5 + 1;
    int end = start + 4;

    int total = 0;

    for (int i = start; i <= end; i++) {
      if (isMateriCompleted(i)) {
        total++;
      }
    }

    return total;
  }

  // =====================================================
  // LOCK KONSEP MATERI
  // =====================================================

  static bool isMateriKonsepUnlocked(
    int konsepIndex,
  ) {
    if (konsepIndex == 0) return true;

    int previousKonsep = konsepIndex - 1;

    return getMateriProgress(
          previousKonsep,
        ) >=
        5;
  }

  // =====================================================
  // RESET
  // =====================================================

  static Future<void> resetAll() async {
    await _box.clear();

    await init();
  }

  // =====================================================
  // TOTAL PROGRESS GAME
  // =====================================================

  static int getTotalGameProgress() {
    List completed = _box.get(
      'completedLevels',
      defaultValue: [],
    );

    return completed.length;
  }

  // =====================================================
  // TOTAL PROGRESS MATERI
  // =====================================================

  static int getTotalMateriProgress() {
    List completed = _box.get(
      'completedMateri',
      defaultValue: [],
    );

    return completed.length;
  }
}