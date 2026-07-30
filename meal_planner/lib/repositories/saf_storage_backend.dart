import 'package:flutter/services.dart';

import 'storage_backend.dart';

/// StorageBackend backed by Android's Storage Access Framework via a
/// custom MethodChannel ([SafPlugin] on the Kotlin side).
///
/// [treeUri] is the `content://` URI string returned by [openDocumentTree].
/// The OS persists the permission across app restarts automatically.
///
/// The Kotlin side only knows flat file names, so the per-entity key
/// `recipes/<id>.json` is stored as `recipes__<id>.json`. This keeps Android
/// sync working without SAF sub-directory support; the real
/// `SafSyncTarget` (phase 5 of the sync rework) replaces this backend and
/// stores true directories.
class SafStorageBackend extends SyncableStorageBackend {
  static const _channel = MethodChannel('com.example.meal_planner/saf');
  static const _separator = '__';

  final String treeUri;

  const SafStorageBackend({required this.treeUri});

  /// Opens the SAF folder picker and returns the chosen tree URI string,
  /// or null if the user cancelled.
  static Future<String?> openDocumentTree() async {
    return await _channel.invokeMethod<String>('openDocumentTree');
  }

  static String _encode(String key) => key.replaceAll('/', _separator);
  static String _decode(String name) => name.replaceAll(_separator, '/');

  @override
  Future<String?> read(String key) async {
    return await _channel.invokeMethod<String>('readFile', {
      'treeUri': treeUri,
      'name': _encode(key),
    });
  }

  @override
  Future<void> write(String key, String value) async {
    await _channel.invokeMethod<void>('writeFile', {
      'treeUri': treeUri,
      'name': _encode(key),
      'content': value,
    });
  }

  @override
  Future<void> delete(String key) async {
    await _channel.invokeMethod<void>('deleteFile', {
      'treeUri': treeUri,
      'name': _encode(key),
    });
  }

  @override
  Future<List<String>> list(String dir) async {
    final prefix = '${_encode(dir)}$_separator';
    final all = await _rawNames();
    return all
        .where((n) => n.startsWith(prefix))
        .map((n) => n.substring(prefix.length))
        .where((n) => !n.contains(_separator))
        .toList();
  }

  /// Returns the last-modified timestamp of [key] as [DateTime], or null.
  @override
  Future<DateTime?> getLastModified(String key) async {
    final ms = await _channel.invokeMethod<int>('getLastModified', {
      'treeUri': treeUri,
      'name': _encode(key),
    });
    if (ms == null || ms == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Lists all `.json` keys in the tree (excludes `.backup` files).
  @override
  Future<List<String>> listKeys() async =>
      (await _rawNames()).map(_decode).toList();

  Future<List<String>> _rawNames() async {
    final result = await _channel.invokeListMethod<String>('listFiles', {
      'treeUri': treeUri,
    });
    return result ?? [];
  }
}
