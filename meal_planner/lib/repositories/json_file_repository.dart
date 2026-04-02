import 'dart:convert';
import 'dart:io';

import 'storage_backend.dart';

/// Abstract base class that persists a `List<T>` as JSON
/// via a platform-agnostic [StorageBackend].
abstract class JsonFileRepository<T> {
  final String fileName;
  final StorageBackend storage;

  JsonFileRepository({required this.fileName, required this.storage});

  /// Convert a JSON map to a domain object.
  T fromJson(Map<String, dynamic> json);

  /// Convert a domain object to a JSON map.
  Map<String, dynamic> toJson(T item);

  /// Read all items. Returns an empty list if no data exists
  /// or the data is invalid.
  Future<List<T>> readAll() async {
    try {
      final content = await storage.read(fileName);
      if (content == null || content.trim().isEmpty) return <T>[];

      final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
      return jsonList
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <T>[];
    }
  }

  /// Overwrite stored data with the given list.
  /// Throws [StorageException] if the write fails.
  Future<void> writeAll(List<T> items) async {
    try {
      final jsonList = items.map(toJson).toList();
      await storage.write(fileName, jsonEncode(jsonList));
    } on IOException catch (e) {
      throw StorageException('Datei konnte nicht geschrieben werden: $e');
    }
  }

  /// Insert or update an item identified by [getId].
  Future<void> upsert(T item, String Function(T) getId) async {
    final items = await readAll();
    final id = getId(item);
    final index = items.indexWhere((e) => getId(e) == id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }
    await writeAll(items);
  }

  /// Delete an item by id. Returns `true` if an item was removed.
  Future<bool> deleteById(String id, String Function(T) getId) async {
    final items = await readAll();
    final lengthBefore = items.length;
    items.removeWhere((e) => getId(e) == id);
    if (items.length < lengthBefore) {
      await writeAll(items);
      return true;
    }
    return false;
  }
}

/// Exception thrown when a storage I/O operation fails.
class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => message;
}
