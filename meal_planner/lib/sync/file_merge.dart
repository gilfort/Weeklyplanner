/// What one file's sync cycle concluded.
enum SyncOutcome {
  /// Neither side has this entity.
  absent,

  /// Both sides already agree; only the base snapshot needs refreshing.
  inSync,

  /// Remote moved ahead while local stood still — fast-forward.
  pulled,

  /// Local moved ahead while remote stood still — fast-forward.
  pushed,

  /// Both sides changed; the result is a three-way merge of the two.
  merged,

  /// Both sides changed and no common ancestor was available, so the newer
  /// file won wholesale. Field-level merging was not possible here.
  conflictResolved,
}

/// The outcome of reconciling one entity file, plus what to do about it.
///
/// [merged] doubles as the new base snapshot: it is the version both sides
/// hold once [writeLocal] and [writeRemote] have been carried out.
class SyncDecision<T> {
  final T? merged;
  final bool writeLocal;
  final bool writeRemote;
  final SyncOutcome outcome;

  const SyncDecision({
    required this.merged,
    required this.writeLocal,
    required this.writeRemote,
    required this.outcome,
  });

  @override
  String toString() =>
      'SyncDecision($outcome, writeLocal: $writeLocal, writeRemote: $writeRemote)';
}

/// Decides what one entity file's sync cycle should do.
///
/// [base] is the version both sides last agreed on, persisted locally. Its
/// absence means this device has never synced this entity, which is why a
/// two-way conflict there cannot be merged field by field.
///
/// Pure: it reads nothing and writes nothing. The caller performs the writes
/// and stores [SyncDecision.merged] as the new base snapshot.
SyncDecision<T> decideSync<T>({
  required T? local,
  required T? base,
  required T? remote,
  required T Function(T base, T local, T remote) merge,
  required bool preferRemote,
}) {
  if (local == null && remote == null) {
    return const SyncDecision(
      merged: null,
      writeLocal: false,
      writeRemote: false,
      outcome: SyncOutcome.absent,
    );
  }

  if (local == null) {
    // New to this device, or the local copy is gone; take the remote.
    return SyncDecision(
      merged: remote,
      writeLocal: true,
      writeRemote: false,
      outcome: SyncOutcome.pulled,
    );
  }

  if (remote == null) {
    // Never uploaded, or the remote copy vanished. Deletions travel as
    // tombstones inside the file, so a missing file is never a delete —
    // push the local version back up.
    return SyncDecision(
      merged: local,
      writeLocal: false,
      writeRemote: true,
      outcome: SyncOutcome.pushed,
    );
  }

  if (local == remote) {
    return SyncDecision(
      merged: local,
      writeLocal: false,
      writeRemote: false,
      outcome: SyncOutcome.inSync,
    );
  }

  if (base == null) {
    final winner = preferRemote ? remote : local;
    return SyncDecision(
      merged: winner,
      writeLocal: preferRemote,
      writeRemote: !preferRemote,
      outcome: SyncOutcome.conflictResolved,
    );
  }

  if (local == base) {
    return SyncDecision(
      merged: remote,
      writeLocal: true,
      writeRemote: false,
      outcome: SyncOutcome.pulled,
    );
  }

  if (remote == base) {
    return SyncDecision(
      merged: local,
      writeLocal: false,
      writeRemote: true,
      outcome: SyncOutcome.pushed,
    );
  }

  final result = merge(base, local, remote);
  return SyncDecision(
    merged: result,
    writeLocal: result != local,
    writeRemote: result != remote,
    outcome: SyncOutcome.merged,
  );
}
