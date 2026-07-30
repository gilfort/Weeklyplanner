import 'package:flutter/services.dart';

import 'storage_backend.dart';

/// StorageBackend backed by Android's Storage Access Framework via a
/// custom MethodChannel ([SafPlugin] on the Kotlin side).
///
/// [treeUri] is the `content://` URI string returned by [openDocumentTree].
/// The OS persists the permission across app restarts automatically.
class SafStorageBackend extends SyncableStorageBackend {
  static const _channel = MethodChannel('com.example.meal_planner/saf');

  final String treeUri;

  const SafStorageBackend({required this.treeUri});

  /// Opens the SAF folder picker and returns the chosen tree URI string,
  /// or null if the user cancelled.
  static Future<String?> openDocumentTree() async {
    return await _channel.invokeMethod<String>('openDocumentTree');
  }

  @override
  Future<String?> read(String key) async {
    return await _channel.invokeMethod<String>('readFile', {
      'treeUri': treeUri,
      'name': key,
    });
  }

  @override
  Future<void> write(String key, String value) async {
    await _channel.invokeMethod<void>('writeFile', {
      'treeUri': treeUri,
      'name': key,
      'content': value,
    });
  }

  /// Returns the last-modified timestamp of [key] as [DateTime], or null.
  @override
  Future<DateTime?> getLastModified(String key) async {
    final ms = await _channel.invokeMethod<int>('getLastModified', {
      'treeUri': treeUri,
      'name': key,
    });
    if (ms == null || ms == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Lists all `.json` file names in the tree (excludes `.backup` files).
  @override
  Future<List<String>> listKeys() async {
    final result = await _channel.invokeListMethod<String>('listFiles', {
      'treeUri': treeUri,
    });
    return result ?? [];
  }
}
