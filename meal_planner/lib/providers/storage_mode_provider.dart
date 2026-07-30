import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'storage_mode_provider.g.dart';

/// Where the app persists its JSON data.
enum StorageMode {
  /// Default: documents directory or a user-chosen local folder.
  local,

  /// Google Drive folder selected by the user (Android only).
  googleDrive,
}

/// Persisted across launches via SharedPreferences.
@Riverpod(keepAlive: true)
class CurrentStorageMode extends _$CurrentStorageMode {
  static const _prefKey = 'storage_mode';

  @override
  Future<StorageMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_prefKey);
    return val == StorageMode.googleDrive.name
        ? StorageMode.googleDrive
        : StorageMode.local;
  }

  Future<void> setMode(StorageMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
    state = AsyncData(mode);
  }
}
