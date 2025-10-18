import 'package:hive/hive.dart';

class DBHelper {
  static late Box _box;

  // Inisialisasi Hive box
  static Future<void> init() async {
    _box = await Hive.openBox('gameProgress');
    if (!_box.containsKey('unlockedLevel')) {
      await _box.put('unlockedLevel', 1);
    }
  }

  // Ambil level terakhir yang sudah dibuka
  static int getUnlockedLevel() {
    return _box.get('unlockedLevel', defaultValue: 1);
  }

  // Simpan level berikutnya setelah selesai
  static Future<void> unlockNextLevel(int currentLevel) async {
    final currentUnlocked = getUnlockedLevel();
    final nextLevel = currentLevel + 1;

    if (nextLevel > currentUnlocked) {
      await _box.put('unlockedLevel', nextLevel);
    }
  }

  // Opsional: reset progress
  static Future<void> resetProgress() async {
    await _box.put('unlockedLevel', 1);
  }
}
