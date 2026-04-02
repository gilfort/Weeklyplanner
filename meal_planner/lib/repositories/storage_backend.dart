/// Abstract storage backend for reading/writing JSON strings.
/// Implementations differ per platform (file I/O vs localStorage).
abstract class StorageBackend {
  /// Read the raw JSON string for [key]. Returns `null` if not found.
  Future<String?> read(String key);

  /// Write a raw JSON string for [key].
  Future<void> write(String key, String value);
}
