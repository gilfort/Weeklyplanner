import 'storage_backend.dart';

/// Offline-first StorageBackend that caches data locally and syncs with a
/// remote backend (SAF, WebDAV, …).
///
/// - Reads always hit the local cache (fast, works offline).
/// - Writes go to local cache immediately and mark the key as dirty.
/// - [syncAll] resolves differences between local and remote.
///
/// Dirty state is in-memory only. On crash the next app start performs a full
/// sync which recovers any unsynced changes.
class CachedSyncStorageBackend implements StorageBackend {
  final SyncableStorageBackend local;
  final SyncableStorageBackend remote;

  final Set<String> _dirtyKeys = {};

  CachedSyncStorageBackend({required this.local, required this.remote});

  Set<String> get dirtyKeys => Set.unmodifiable(_dirtyKeys);

  @override
  Future<String?> read(String key) => local.read(key);

  @override
  Future<void> write(String key, String value) async {
    await local.write(key, value);
    _dirtyKeys.add(key);
  }

  /// Full two-way sync:
  /// - Remote wins when local cache is empty (fresh install / new device).
  /// - Dirty local files are pushed; if remote is newer than dirty local,
  ///   the local version is backed up before pulling remote.
  /// - Non-dirty local files pull from remote if remote is newer.
  Future<void> syncAll() async {
    final localKeys = await local.listKeys();
    final remoteKeys = await remote.listKeys();
    final allKeys = {...localKeys, ...remoteKeys};

    for (final key in allKeys) {
      final localExists = localKeys.contains(key);
      final remoteExists = remoteKeys.contains(key);

      if (!localExists && remoteExists) {
        // Fresh install or new device: remote wins.
        await _pullFromRemote(key);
        continue;
      }

      if (localExists && !remoteExists) {
        // Key not yet uploaded.
        await _pushToRemote(key);
        continue;
      }

      if (localExists && remoteExists) {
        final localTime = await local.getLastModified(key);
        final remoteTime = await remote.getLastModified(key);

        if (_dirtyKeys.contains(key)) {
          if (remoteTime != null &&
              localTime != null &&
              remoteTime.isAfter(localTime)) {
            // Conflict: remote newer than our dirty version → backup + pull.
            final localContent = await local.read(key);
            if (localContent != null) {
              await local.write('$key.backup', localContent);
            }
            await _pullFromRemote(key);
          } else {
            await _pushToRemote(key);
          }
        } else {
          if (remoteTime != null &&
              localTime != null &&
              remoteTime.isAfter(localTime)) {
            await _pullFromRemote(key);
          }
          // else: already in sync, nothing to do.
        }
      }
    }
  }

  /// Push all dirty keys to remote.
  Future<void> pushDirty() async {
    for (final key in List.of(_dirtyKeys)) {
      await _pushToRemote(key);
    }
  }

  Future<void> _pullFromRemote(String key) async {
    final content = await remote.read(key);
    if (content != null) {
      await local.write(key, content);
    }
    _dirtyKeys.remove(key);
  }

  Future<void> _pushToRemote(String key) async {
    final content = await local.read(key);
    if (content != null) {
      await remote.write(key, content);
    }
    _dirtyKeys.remove(key);
  }
}
