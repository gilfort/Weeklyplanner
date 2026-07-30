import 'package:shared_preferences/shared_preferences.dart';

import 'storage_backend.dart';

/// Storage backend that persists data in SharedPreferences (localStorage on Web).
/// Keys keep their `dir/name.json` form; [list] filters by prefix.
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

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }

  @override
  Future<List<String>> list(String dir) async {
    final prefs = await SharedPreferences.getInstance();
    final dirPrefix = '$_prefix$dir/';
    return prefs
        .getKeys()
        .where((k) => k.startsWith(dirPrefix))
        .map((k) => k.substring(dirPrefix.length))
        .where((name) => !name.contains('/') && name.endsWith('.json'))
        .toList();
  }
}
