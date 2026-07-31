import 'dart:async';

import '../sync/sync_engine.dart';

enum SyncStatus { idle, syncing, error }

class SyncStatusDetail {
  final SyncStatus status;
  final String? errorMessage;

  /// The last completed run, for a UI that wants to say what happened.
  final SyncReport? report;

  const SyncStatusDetail(this.status, {this.errorMessage, this.report});
}

/// One sync cycle. Whatever transport is configured hides behind this.
typedef SyncCycle = Future<SyncReport> Function();

/// Drives sync in the foreground only: on app start, on resume, after a
/// debounce once the user changed something, and on manual refresh.
///
/// No periodic timer and no background worker — the design deliberately keeps
/// sync tied to moments the user is actually looking at the app.
class SyncService {
  final SyncCycle cycle;

  /// How long to wait after the last write before pushing. Long enough that
  /// typing a recipe is one sync, short enough that the other device sees it
  /// before anyone walks to the shop.
  final Duration debounce;

  Timer? _debounceTimer;
  bool _running = false;
  bool _rerunRequested = false;

  final _statusController = StreamController<SyncStatusDetail>.broadcast();

  Stream<SyncStatusDetail> get status => _statusController.stream;

  SyncService({
    required this.cycle,
    this.debounce = const Duration(seconds: 3),
  });

  /// Runs a cycle now. Concurrent calls collapse into one, with a single
  /// re-run queued if writes arrived while the cycle was in flight.
  Future<SyncReport?> syncNow() async {
    if (_running) {
      _rerunRequested = true;
      return null;
    }
    _running = true;
    _emit(const SyncStatusDetail(SyncStatus.syncing));
    try {
      final report = await cycle();
      _emit(SyncStatusDetail(SyncStatus.idle, report: report));
      return report;
    } catch (e) {
      _emit(SyncStatusDetail(SyncStatus.error, errorMessage: e.toString()));
      return null;
    } finally {
      _running = false;
      if (_rerunRequested) {
        _rerunRequested = false;
        unawaited(syncNow());
      }
    }
  }

  /// Called on every local write. Coalesces a burst of edits into one cycle.
  void scheduleSync() {
    // The engine writes through the same backend, so its own merge results
    // would otherwise schedule an endless chain of cycles.
    if (_running) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, syncNow);
  }

  void dispose() {
    _debounceTimer?.cancel();
    _statusController.close();
  }

  void _emit(SyncStatusDetail detail) {
    if (!_statusController.isClosed) _statusController.add(detail);
  }
}
