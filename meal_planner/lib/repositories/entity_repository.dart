import 'dart:convert';
import 'dart:io';

import '../models/schema.dart';
import 'storage_backend.dart';

/// Persists entities as one JSON file per entity under [dirName].
///
/// Every file carries a [kSchemaVersion] envelope so a future layout change can
/// be detected instead of silently mis-parsed, and deletions are *soft* — the
/// entity file stays with `deleted: true` until [purgeTombstones] removes it.
/// Both are requirements of the file-based sync engine: a missing file must
/// mean "not synced yet", never "deleted on the other device".
abstract class EntityRepository<T> {
  final StorageBackend storage;
  final String dirName;

  EntityRepository({required this.storage, required this.dirName});

  /// Convert a JSON map to a domain object.
  T fromJson(Map<String, dynamic> json);

  /// Convert a domain object to a JSON map.
  Map<String, dynamic> toJson(T item);

  /// Stable id of [item]; also its file name.
  String idOf(T item);

  bool isDeleted(T item);
  DateTime? deletedAtOf(T item);

  /// Returns a copy of [item] marked as deleted at [at].
  T markDeleted(T item, DateTime at);

  /// Ids are UUIDs or week keys — anything else would leak user text into
  /// file paths and break on the stricter sync targets.
  static final _safeId = RegExp(r'^[A-Za-z0-9._-]+$');

  String pathFor(String id) {
    if (!_safeId.hasMatch(id)) {
      throw ArgumentError.value(id, 'id', 'Not usable as a file name');
    }
    return '$dirName/$id.json';
  }

  /// Read every entity in the directory. Unreadable or foreign-version files
  /// are skipped rather than failing the whole read.
  Future<List<T>> readAll({bool includeDeleted = false}) async {
    final names = await storage.list(dirName);
    final items = <T>[];
    for (final name in names) {
      final content = await storage.read('$dirName/$name');
      final item = _decode(content);
      if (item == null) continue;
      if (!includeDeleted && isDeleted(item)) continue;
      items.add(item);
    }
    return items;
  }

  Future<T?> findById(String id, {bool includeDeleted = false}) async {
    final item = _decode(await storage.read(pathFor(id)));
    if (item == null) return null;
    if (!includeDeleted && isDeleted(item)) return null;
    return item;
  }

  /// Insert or overwrite [item]'s file.
  Future<void> upsert(T item) async {
    try {
      await storage.write(pathFor(idOf(item)), _encode(item));
    } on IOException catch (e) {
      throw StorageException('Datei konnte nicht geschrieben werden: $e');
    }
  }

  /// Soft-delete: writes a tombstone. Returns `false` if nothing was there
  /// or it was already deleted.
  Future<bool> delete(String id, {DateTime? now}) async {
    final existing = await findById(id);
    if (existing == null) return false;
    await upsert(markDeleted(existing, now ?? DateTime.now()));
    return true;
  }

  /// Permanently removes tombstones deleted longer than [retention] ago.
  /// Returns how many files were removed.
  Future<int> purgeTombstones({
    required DateTime now,
    Duration retention = kTombstoneRetention,
  }) async {
    final all = await readAll(includeDeleted: true);
    var removed = 0;
    for (final item in all) {
      if (!isDeleted(item)) continue;
      final at = deletedAtOf(item);
      if (at == null || now.difference(at) < retention) continue;
      await storage.delete(pathFor(idOf(item)));
      removed++;
    }
    return removed;
  }

  String _encode(T item) => jsonEncode({
        'schemaVersion': kSchemaVersion,
        'data': toJson(item),
      });

  T? _decode(String? content) {
    if (content == null || content.trim().isEmpty) return null;
    try {
      final envelope = jsonDecode(content) as Map<String, dynamic>;
      // No migrations exist yet, so anything but the current version is data
      // this build must not touch — skipping keeps it intact for a newer build.
      if (envelope['schemaVersion'] != kSchemaVersion) return null;
      return fromJson(envelope['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

/// Exception thrown when a storage I/O operation fails.
class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => message;
}
