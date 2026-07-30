import 'dart:async';

import 'storage_backend.dart';

/// Offline-first wrapper: reads/writes a local [StorageBackend] immediately
/// and asynchronously syncs to a remote one. Remote-wins on first access
/// per session (so other devices' edits propagate on app start).
class CachedSyncStorageBackend implements StorageBackend {
  final StorageBackend local;
  final StorageBackend remote;

  /// Keys whose local write has not yet succeeded on the remote.
  final Set<String> _dirty = {};

  /// Keys that have already been reconciled with the remote this session.
  final Set<String> _pulled = {};

  CachedSyncStorageBackend({required this.local, required this.remote});

  @override
  Future<String?> read(String key) async {
    // On first session access: try remote first (other devices may have
    // newer data). Skip pull if we have local unsynced changes.
    if (!_pulled.contains(key) && !_dirty.contains(key)) {
      _pulled.add(key);
      try {
        final remoteContent = await remote.read(key);
        if (remoteContent != null) {
          await local.write(key, remoteContent);
          return remoteContent;
        }
        // Remote has nothing — fall through to local (empty or initial).
      } catch (_) {
        // Offline / auth failure — fall back to cache.
      }
    }
    return local.read(key);
  }

  @override
  Future<void> write(String key, String value) async {
    await local.write(key, value);
    _pulled.add(key);
    _dirty.add(key);
    unawaited(_pushInBackground(key, value));
  }

  Future<void> _pushInBackground(String key, String value) async {
    try {
      await remote.write(key, value);
      _dirty.remove(key);
    } catch (_) {
      // Stays dirty; retried by [flushDirty] or on next write.
    }
  }

  /// Pushes all dirty keys to the remote. Safe to call on app resume.
  Future<void> flushDirty() async {
    for (final key in _dirty.toList()) {
      final content = await local.read(key);
      if (content == null) {
        _dirty.remove(key);
        continue;
      }
      try {
        await remote.write(key, content);
        _dirty.remove(key);
      } catch (_) {
        // Keep for next attempt.
      }
    }
  }

  bool get hasPendingChanges => _dirty.isNotEmpty;
}
