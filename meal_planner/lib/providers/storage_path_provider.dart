import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'storage_path_provider.g.dart';

/// Manages the user-configured storage directory path.
/// When `null`, the app uses the default documents directory.
@Riverpod(keepAlive: true)
class StoragePath extends _$StoragePath {
  static const _prefKey = 'storage_path';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  Future<void> setPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.trim().isEmpty) {
      await prefs.remove(_prefKey);
      state = const AsyncData(null);
    } else {
      final trimmed = path.trim();
      await prefs.setString(_prefKey, trimmed);
      state = AsyncData(trimmed);
    }
  }
}
