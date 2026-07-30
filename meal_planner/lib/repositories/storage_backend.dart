/// Abstract storage backend for reading/writing JSON strings.
/// Implementations differ per platform (file I/O vs localStorage vs WebDAV).
///
/// Keys are POSIX-style relative paths — `recipes/<id>.json`,
/// `weeks/2025-W14.json` — because the sync layout stores one file per entity.
/// Backends that cannot represent directories must encode the separator
/// themselves; callers always use `/`.
abstract class StorageBackend {
  const StorageBackend();

  /// Read the raw JSON string for [key]. Returns `null` if not found.
  Future<String?> read(String key);

  /// Write a raw JSON string for [key], creating parent directories.
  Future<void> write(String key, String value);

  /// Remove [key]. Missing keys are not an error.
  Future<void> delete(String key);

  /// File names directly inside [dir] — bare names, no directory part.
  /// Returns an empty list when the directory does not exist.
  Future<List<String>> list(String dir);
}

/// Storage backend that additionally supports listing every key and querying
/// last-modified timestamps. Required for any backend used as the *remote*
/// side of [CachedSyncStorageBackend], because sync needs to compare
/// per-key mtimes between local and remote.
abstract class SyncableStorageBackend extends StorageBackend {
  const SyncableStorageBackend();

  /// Lists all `.json` keys in the backend, recursively, as relative paths
  /// (excludes `.backup` and partial `.tmp` files).
  Future<List<String>> listKeys();

  /// Returns the last-modified time of [key], or null if missing.
  Future<DateTime?> getLastModified(String key);
}
