import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'storage_backend.dart';

/// Storage backend that persists data as files in the app documents directory.
/// Works on Android, Windows, Linux, macOS.
class FileStorageBackend extends SyncableStorageBackend {
  final Directory? directoryOverride;

  FileStorageBackend({this.directoryOverride});

  Future<Directory> _root() async =>
      directoryOverride ?? await getApplicationDocumentsDirectory();

  Future<File> _fileFor(String key) async {
    final dir = await _root();
    return File(p.join(dir.path, p.joinAll(p.posix.split(key))));
  }

  @override
  Future<String?> read(String key) async {
    try {
      final file = await _fileFor(key);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return content.trim().isEmpty ? null : content;
    } catch (_) {
      return null;
    }
  }

  /// Writes via a temp file + rename so a crash mid-write cannot leave a
  /// half-written entity behind for the sync engine to pick up.
  @override
  Future<void> write(String key, String value) async {
    final file = await _fileFor(key);
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(value, flush: true);
    await tmp.rename(file.path);
  }

  @override
  Future<void> delete(String key) async {
    final file = await _fileFor(key);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<List<String>> list(String dir) async {
    final root = await _root();
    final target = Directory(p.join(root.path, p.joinAll(p.posix.split(dir))));
    if (!await target.exists()) return [];
    return target
        .listSync()
        .whereType<File>()
        .map((f) => p.basename(f.path))
        .where(_isDataFile)
        .toList();
  }

  /// Lists all .json keys below the root as `dir/name.json` paths.
  @override
  Future<List<String>> listKeys() async {
    final dir = await _root();
    if (!await dir.exists()) return [];
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => p.posix.joinAll(p.split(p.relative(f.path, from: dir.path))))
        .where((key) => _isDataFile(p.posix.basename(key)))
        .toList();
  }

  /// Returns the last-modified time of [key], or null if the file doesn't exist.
  @override
  Future<DateTime?> getLastModified(String key) async {
    try {
      final file = await _fileFor(key);
      if (!await file.exists()) return null;
      return file.lastModified();
    } catch (_) {
      return null;
    }
  }
}

bool _isDataFile(String name) =>
    name.endsWith('.json') &&
    !name.endsWith('.backup') &&
    !name.endsWith('.tmp');
