import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'storage_backend.dart';

/// Storage backend that persists data as files in the app documents directory.
/// Works on Android, Windows, Linux, macOS.
class FileStorageBackend implements StorageBackend {
  final Directory? directoryOverride;

  FileStorageBackend({this.directoryOverride});

  Future<File> _fileFor(String key) async {
    final dir = directoryOverride ?? await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, key));
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

  @override
  Future<void> write(String key, String value) async {
    final file = await _fileFor(key);
    await file.writeAsString(value, flush: true);
  }
}
