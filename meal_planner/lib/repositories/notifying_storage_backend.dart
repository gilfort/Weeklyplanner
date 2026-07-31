import 'storage_backend.dart';

/// Wraps the local backend and reports every write.
///
/// Every repository writes through one backend, so this is the single place
/// that knows "the user changed something" — cheaper and far harder to forget
/// than calling the sync service from each notifier.
class NotifyingStorageBackend extends SyncableStorageBackend {
  final SyncableStorageBackend inner;
  final void Function() onWrite;

  const NotifyingStorageBackend({required this.inner, required this.onWrite});

  @override
  Future<String?> read(String key) => inner.read(key);

  @override
  Future<void> write(String key, String value) async {
    await inner.write(key, value);
    onWrite();
  }

  @override
  Future<void> delete(String key) async {
    await inner.delete(key);
    onWrite();
  }

  @override
  Future<List<String>> list(String dir) => inner.list(dir);

  @override
  Future<List<String>> listKeys() => inner.listKeys();

  @override
  Future<DateTime?> getLastModified(String key) => inner.getLastModified(key);
}
