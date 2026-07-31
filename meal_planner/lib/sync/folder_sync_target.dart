import 'dart:io';

import 'package:path/path.dart' as p;

import 'sync_target.dart';

/// Thrown when the chosen sync folder cannot be used.
class FolderSyncException implements Exception {
  final String message;
  const FolderSyncException(this.message);

  @override
  String toString() => message;
}

/// A plain directory on this machine — typically one inside a Drive,
/// OneDrive or Nextcloud desktop-sync folder, which is what carries the data
/// between devices. The app never treats it as its own storage; it is a copy
/// the engine reconciles against.
class FolderSyncTarget extends SyncTarget {
  final Directory root;

  const FolderSyncTarget(this.root);

  File _fileFor(String path) =>
      File(p.join(root.path, p.joinAll(p.posix.split(path))));

  @override
  Future<void> ping() async {
    if (!await root.exists()) {
      throw FolderSyncException('Ordner nicht gefunden: ${root.path}');
    }
    // A readable folder we cannot write to would fail silently on every push.
    final probe = File(p.join(root.path, '.mealplanner_write_test'));
    try {
      await probe.writeAsString('', flush: true);
      await probe.delete();
    } on FileSystemException catch (e) {
      throw FolderSyncException('Ordner ist nicht beschreibbar: ${e.message}');
    }
  }

  @override
  Future<List<RemoteFile>> list(String dir) async {
    final target = Directory(p.join(root.path, p.joinAll(p.posix.split(dir))));
    if (!await target.exists()) return const [];
    final files = <RemoteFile>[];
    for (final entity in target.listSync()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (!_isDataFile(name)) continue;
      files.add(RemoteFile(name: name, modified: entity.statSync().modified));
    }
    return files;
  }

  @override
  Future<String?> read(String path) async {
    final file = _fileFor(path);
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    return content.trim().isEmpty ? null : content;
  }

  /// Writes via a temp file + rename, so the desktop sync client never picks
  /// up a half-written file and propagates it to the other device.
  @override
  Future<void> write(String path, String content) async {
    final file = _fileFor(path);
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(content, flush: true);
    await tmp.rename(file.path);
  }

  @override
  Future<void> delete(String path) async {
    final file = _fileFor(path);
    if (await file.exists()) await file.delete();
  }
}

bool _isDataFile(String name) =>
    name.endsWith('.json') &&
    !name.endsWith('.backup') &&
    !name.endsWith('.tmp');
