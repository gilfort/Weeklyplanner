import 'dart:async';

import '../repositories/cached_sync_storage_backend.dart';

enum SyncStatus { idle, syncing, error }

class SyncStatusDetail {
  final SyncStatus status;
  final String? errorMessage;

  const SyncStatusDetail(this.status, {this.errorMessage});
}

/// Manages periodic and on-demand sync between the local cache and the remote
/// SAF backend.
///
/// Lifecycle:
/// - Call [startPeriodicSync] when the app enters the foreground.
/// - Call [stopPeriodicSync] when the app enters the background.
/// - [syncAll] can be called at any time (e.g. on app resume).
class SyncService {
  final CachedSyncStorageBackend backend;

  Timer? _timer;
  static const _syncInterval = Duration(seconds: 30);

  final _statusController =
      StreamController<SyncStatusDetail>.broadcast();

  Stream<SyncStatusDetail> get status => _statusController.stream;

  SyncService({required this.backend});

  Future<void> syncAll() async {
    if (_statusController.isClosed) return;
    _emit(SyncStatusDetail(SyncStatus.syncing));
    try {
      await backend.syncAll();
      _emit(SyncStatusDetail(SyncStatus.idle));
    } catch (e) {
      _emit(SyncStatusDetail(SyncStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> pushDirty() async {
    if (_statusController.isClosed) return;
    _emit(SyncStatusDetail(SyncStatus.syncing));
    try {
      await backend.pushDirty();
      _emit(SyncStatusDetail(SyncStatus.idle));
    } catch (e) {
      _emit(SyncStatusDetail(SyncStatus.error, errorMessage: e.toString()));
    }
  }

  void startPeriodicSync() {
    _timer?.cancel();
    _timer = Timer.periodic(_syncInterval, (_) => syncAll());
  }

  void stopPeriodicSync() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _timer?.cancel();
    _statusController.close();
  }

  void _emit(SyncStatusDetail detail) {
    if (!_statusController.isClosed) {
      _statusController.add(detail);
    }
  }
}
