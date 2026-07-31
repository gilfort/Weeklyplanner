/// Generic three-way merge primitives.
///
/// Every function compares a *local* and a *remote* value against the *base*
/// snapshot — the version both sides last agreed on. That third input is what
/// makes the difference between "the other side changed this" and "the other
/// side simply doesn't have my change yet", which a two-way comparison cannot
/// tell apart. Without it, unchecking an item on one device is
/// indistinguishable from that device never having seen the check.
///
/// These are pure functions: no I/O, no clocks, no transport. Whoever calls
/// them decides which side counts as newer and passes it in as
/// [preferRemote].
library;

/// Merges a single value.
///
/// Only when *both* sides moved away from the base — and to different values —
/// is there a genuine conflict; that is the one case where [preferRemote]
/// decides, silently, per the sync design.
/// Pass [equals] for values whose `==` is not structural — most importantly
/// raw lists, where Dart compares identity.
T mergeValue<T>(
  T base,
  T local,
  T remote, {
  required bool preferRemote,
  bool Function(T, T)? equals,
}) {
  final eq = equals ?? (T a, T b) => a == b;
  if (eq(local, remote)) return local;
  if (eq(local, base)) return remote;
  if (eq(remote, base)) return local;
  return preferRemote ? remote : local;
}

/// Element-wise list equality.
///
/// `List == List` is identity in Dart, so without this every list-valued
/// field would look changed on both sides and land in the conflict branch.
bool listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Merges a set of ids (checked items, exclusions, …).
///
/// Additions and removals are derived against the base, so this handles
/// check *and* uncheck: an id can never be both added and removed relative to
/// the same base, which makes the result conflict-free and independent of
/// which side is "newer".
Set<T> mergeSet<T>(Set<T> base, Set<T> local, Set<T> remote) {
  final added = <T>{
    ...local.difference(base),
    ...remote.difference(base),
  };
  final removed = <T>{
    ...base.difference(local),
    ...base.difference(remote),
  };
  return <T>{...base, ...added}..removeAll(removed);
}

/// Merges a map key by key.
///
/// [mergeEntry] merges two values that both changed; without it such a
/// collision falls back to [preferRemote]. A key present on one side only is
/// judged against the base: absent from the base means it was just added and
/// is kept, present in the base means the other side deleted it.
///
/// When one side deletes a key and the other edits it, the **edit wins**.
/// Losing a partner's edit is worse than a deletion that has to be repeated —
/// re-deleting is one tap, reconstructing a lost entry is not.
Map<K, V> mergeMap<K, V>(
  Map<K, V> base,
  Map<K, V> local,
  Map<K, V> remote, {
  required bool preferRemote,
  V Function(V base, V local, V remote, bool preferRemote)? mergeEntry,
}) {
  final result = <K, V>{};
  for (final key in <K>{...base.keys, ...local.keys, ...remote.keys}) {
    final b = base[key];
    final l = local[key];
    final r = remote[key];

    if (l != null && r != null) {
      if (l == r) {
        result[key] = l;
      } else if (b == null) {
        // Both sides added the same key with different values.
        result[key] = preferRemote ? r : l;
      } else if (l == b) {
        result[key] = r;
      } else if (r == b) {
        result[key] = l;
      } else {
        result[key] = mergeEntry?.call(b, l, r, preferRemote) ??
            (preferRemote ? r : l);
      }
      continue;
    }

    final present = l ?? r;
    if (present == null) continue; // deleted on both sides
    if (b == null) {
      result[key] = present; // freshly added on one side
    } else if (present != b) {
      result[key] = present; // edited on one side, deleted on the other
    }
    // else: unchanged on one side, deleted on the other → stays deleted
  }
  return result;
}

/// Merges a list whose entries carry a stable key, by treating it as a map.
/// Ordering follows the merged key set, not either input list.
List<V> mergeListByKey<K, V>(
  List<V> base,
  List<V> local,
  List<V> remote, {
  required K Function(V) keyOf,
  required bool preferRemote,
  V Function(V base, V local, V remote, bool preferRemote)? mergeEntry,
}) {
  Map<K, V> index(List<V> items) => {for (final item in items) keyOf(item): item};
  return mergeMap(
    index(base),
    index(local),
    index(remote),
    preferRemote: preferRemote,
    mergeEntry: mergeEntry,
  ).values.toList();
}

/// Resolves the soft-delete pair of an entity.
///
/// A deletion always wins over a concurrent edit. Both devices then reach the
/// same tombstone, whereas "edit resurrects" would let a deleted recipe
/// reappear on every sync until someone deletes it on every device at once.
/// The earliest timestamp is kept — that is when the entity actually died.
({bool deleted, DateTime? deletedAt}) mergeDeletion({
  required bool localDeleted,
  required DateTime? localDeletedAt,
  required bool remoteDeleted,
  required DateTime? remoteDeletedAt,
}) {
  if (!localDeleted && !remoteDeleted) {
    return (deleted: false, deletedAt: null);
  }
  final candidates = <DateTime>[
    if (localDeleted && localDeletedAt != null) localDeletedAt,
    if (remoteDeleted && remoteDeletedAt != null) remoteDeletedAt,
  ]..sort();
  return (
    deleted: true,
    deletedAt: candidates.isEmpty ? null : candidates.first,
  );
}
