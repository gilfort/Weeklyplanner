/// Abstract storage backend for reading/writing JSON strings.
/// Implementations differ per platform (file I/O vs localStorage vs WebDAV).
abstract class StorageBackend {
  const StorageBackend();

  /// Read the raw JSON string for [key]. Returns `null` if not found.
  Future<String?> read(String key);

  /// Write a raw JSON string for [key].
  Future<void> write(String key, String value);
}

/// Storage backend that additionally supports listing keys and querying
/// last-modified timestamps. Required for any backend used as the *remote*
/// side of [CachedSyncStorageBackend], because sync needs to compare
/// per-key mtimes between local and remote.
abstract class SyncableStorageBackend extends StorageBackend {
  const SyncableStorageBackend();

  /// Lists all `.json` keys in the backend (excludes `.backup` files).
  Future<List<String>> listKeys();

  /// Returns the last-modified time of [key], or null if missing.
  Future<DateTime?> getLastModified(String key);
}
