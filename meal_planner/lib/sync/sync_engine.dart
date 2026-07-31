import 'dart:convert';

import '../models/schema.dart';
import '../repositories/entity_repository.dart';
import '../repositories/storage_backend.dart';
import '../repositories/unit_repository.dart';
import 'base_snapshot_store.dart';
import 'file_merge.dart';
import 'sync_target.dart';
import 'three_way_merge.dart';

/// What one sync run did.
class SyncReport {
  final int pulled;
  final int pushed;
  final int merged;
  final int conflicts;
  final int unchanged;
  final int purged;

  /// One entry per file that could not be reconciled. A single bad file must
  /// not abort the run — the rest of the household's data still syncs.
  final List<String> failures;

  const SyncReport({
    this.pulled = 0,
    this.pushed = 0,
    this.merged = 0,
    this.conflicts = 0,
    this.unchanged = 0,
    this.purged = 0,
    this.failures = const [],
  });

  int get changed => pulled + pushed + merged + conflicts;
  bool get hasFailures => failures.isNotEmpty;

  SyncReport operator +(SyncReport other) => SyncReport(
        pulled: pulled + other.pulled,
        pushed: pushed + other.pushed,
        merged: merged + other.merged,
        conflicts: conflicts + other.conflicts,
        unchanged: unchanged + other.unchanged,
        purged: purged + other.purged,
        failures: [...failures, ...other.failures],
      );

  @override
  String toString() => 'SyncReport(pulled: $pulled, pushed: $pushed, '
      'merged: $merged, conflicts: $conflicts, unchanged: $unchanged, '
      'purged: $purged, failures: ${failures.length})';
}

/// Reconciles the app's private storage with a [SyncTarget], one entity file
/// at a time.
///
/// There is no dirty queue: whether a file needs pushing follows from
/// comparing it to the base snapshot on disk, so a crash mid-edit cannot lose
/// the pending write. That was the structural bug in the old
/// `CachedSyncStorageBackend`.
///
/// [local] must be the same backend the repositories write through, otherwise
/// the engine would reconcile a different copy than the app is using.
class SyncEngine {
  final SyncableStorageBackend local;
  final SyncTarget target;
  final BaseSnapshotStore base;

  const SyncEngine({
    required this.local,
    required this.target,
    required this.base,
  });

  /// Runs one full cycle over every collection plus the unit list.
  Future<SyncReport> syncAll(
    List<EntityRepository<Object?>> repositories, {
    DateTime? now,
  }) async {
    var report = const SyncReport();
    for (final repo in repositories) {
      report += await syncCollection(repo, now: now);
    }
    return report + await syncUnits();
  }

  /// Reconciles one entity directory.
  Future<SyncReport> syncCollection<T>(
    EntityRepository<T> repo, {
    DateTime? now,
  }) async {
    final List<String> localNames;
    final List<RemoteFile> remoteFiles;
    final List<String> baseNames;
    try {
      localNames = await local.list(repo.dirName);
      remoteFiles = await target.list(repo.dirName);
      baseNames = await base.list(repo.dirName);
    } catch (e) {
      return SyncReport(failures: ['${repo.dirName}: $e']);
    }

    final remoteByName = {for (final f in remoteFiles) f.name: f};
    final names = <String>{...localNames, ...remoteByName.keys, ...baseNames};

    var report = const SyncReport();
    for (final name in names) {
      report += await _syncFile(repo, name, remoteByName[name], now);
    }
    return report;
  }

  Future<SyncReport> _syncFile<T>(
    EntityRepository<T> repo,
    String name,
    RemoteFile? remoteFile,
    DateTime? now,
  ) async {
    final key = '${repo.dirName}/$name';
    try {
      final localEntity = repo.decode(await local.read(key));
      final baseEntity = repo.decode(await base.read(key));
      final remoteEntity = repo.decode(await target.read(key));

      final preferRemote = await _remoteIsNewer(key, remoteFile);

      final decision = decideSync<T>(
        local: localEntity,
        base: baseEntity,
        remote: remoteEntity,
        preferRemote: preferRemote,
        merge: (b, l, r) => repo.merge(b, l, r, preferRemote: preferRemote),
      );

      final result = decision.merged;
      if (result == null) return const SyncReport();

      final encoded = repo.encode(result);
      if (decision.writeLocal) await local.write(key, encoded);
      if (decision.writeRemote) await target.write(key, encoded);
      // The snapshot is refreshed even for an in-sync file: on the very first
      // run there is no snapshot yet, and without one the next real conflict
      // would have no base to merge against.
      await base.write(key, encoded);

      if (await _purgeIfExpired(repo, key, result, now)) {
        return const SyncReport(purged: 1);
      }

      return switch (decision.outcome) {
        SyncOutcome.pulled => const SyncReport(pulled: 1),
        SyncOutcome.pushed => const SyncReport(pushed: 1),
        SyncOutcome.merged => const SyncReport(merged: 1),
        SyncOutcome.conflictResolved => const SyncReport(conflicts: 1),
        SyncOutcome.inSync => const SyncReport(unchanged: 1),
        SyncOutcome.absent => const SyncReport(),
      };
    } catch (e) {
      return SyncReport(failures: ['$key: $e']);
    }
  }

  /// Drops a tombstone once it is older than the retention window.
  ///
  /// Safe to do on both sides at this point: [merged] is what local and
  /// remote now agree on, so neither can reintroduce the entity afterwards.
  Future<bool> _purgeIfExpired<T>(
    EntityRepository<T> repo,
    String key,
    T merged,
    DateTime? now,
  ) async {
    if (!repo.isDeleted(merged)) return false;
    final deletedAt = repo.deletedAtOf(merged);
    if (deletedAt == null) return false;
    if ((now ?? DateTime.now()).difference(deletedAt) < kTombstoneRetention) {
      return false;
    }
    await local.delete(key);
    await target.delete(key);
    await base.delete(key);
    return true;
  }

  /// Which side wins a genuine field conflict.
  ///
  /// These are wall clocks on two different machines, so the comparison is
  /// approximate — but it only ever decides fields *both* sides changed to
  /// different values. Everything else merges deterministically, which is why
  /// clock skew can no longer cost a whole file the way it did under
  /// last-write-wins. Unknown timestamps keep the local version.
  Future<bool> _remoteIsNewer(String key, RemoteFile? remoteFile) async {
    final remoteTime = remoteFile?.modified;
    if (remoteTime == null) return false;
    final localTime = await local.getLastModified(key);
    if (localTime == null) return true;
    return remoteTime.isAfter(localTime);
  }

  /// The unit list is a plain string array, not an entity, and merges as a
  /// set: a unit added on either device is kept, one removed on either device
  /// goes away.
  Future<SyncReport> syncUnits() async {
    const key = UnitRepository.fileName;
    try {
      final baseUnits = _decodeUnits(await base.read(key)) ?? <String>{};
      // A missing file means "this side has no news", not "this side wants it
      // empty" — otherwise a target that was never written to would wipe the
      // local units on first sync.
      final localUnits = _decodeUnits(await local.read(key)) ?? baseUnits;
      final remoteUnits = _decodeUnits(await target.read(key)) ?? baseUnits;

      final merged = mergeSet(baseUnits, localUnits, remoteUnits);
      if (merged.isEmpty) return const SyncReport();

      final encoded = jsonEncode(merged.toList());
      final writeLocal = !_sameSet(merged, localUnits);
      final writeRemote = !_sameSet(merged, remoteUnits);

      if (writeLocal) await local.write(key, encoded);
      if (writeRemote) await target.write(key, encoded);
      await base.write(key, encoded);

      if (writeLocal && writeRemote) return const SyncReport(merged: 1);
      if (writeLocal) return const SyncReport(pulled: 1);
      if (writeRemote) return const SyncReport(pushed: 1);
      return const SyncReport(unchanged: 1);
    } catch (e) {
      return SyncReport(failures: ['$key: $e']);
    }
  }

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  static Set<String>? _decodeUnits(String? content) {
    if (content == null || content.trim().isEmpty) return null;
    try {
      final list = jsonDecode(content) as List<dynamic>;
      return list.cast<String>().toSet();
    } catch (_) {
      return null;
    }
  }
}
