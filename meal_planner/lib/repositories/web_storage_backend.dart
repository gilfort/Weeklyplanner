import 'package:shared_preferences/shared_preferences.dart';

import 'storage_backend.dart';

/// Storage backend that persists data in SharedPreferences (localStorage on Web).
class WebStorageBackend implements StorageBackend {
  static const _prefix = 'meal_planner_';

  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key');
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', value);
  }
}
