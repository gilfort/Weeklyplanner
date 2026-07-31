/// One file as the sync target reports it.
class RemoteFile {
  /// Bare file name inside the listed directory — no path.
  final String name;

  /// Last-modified time as the target reports it, or null when it cannot say.
  ///
  /// This is a clock on the *other* side. It is only ever used to break a tie
  /// between two genuinely conflicting field edits, never to decide what
  /// merges — a skewed clock therefore costs at most one field, not a file.
  final DateTime? modified;

  const RemoteFile({required this.name, this.modified});

  @override
  String toString() => 'RemoteFile($name, $modified)';
}

/// The storage the household actually shares: a synced folder, a WebDAV
/// account, an Android document tree.
///
/// Paths are POSIX-style and relative to the target's root — `recipes/r1.json`.
/// Implementations create missing directories on write.
abstract class SyncTarget {
  const SyncTarget();

  /// Files directly inside [dir]. Empty when the directory does not exist —
  /// a target that has never been written to is not an error.
  Future<List<RemoteFile>> list(String dir);

  /// Contents of [path], or null when it does not exist.
  Future<String?> read(String path);

  /// Writes [content] to [path], creating parent directories.
  Future<void> write(String path, String content);

  /// Removes [path]. Missing paths are not an error.
  ///
  /// Only used to purge expired tombstones — entity deletions travel as
  /// `deleted` flags inside the file, never as a missing file.
  Future<void> delete(String path);

  /// Cheap reachability check. Throws when the target cannot be used.
  Future<void> ping();
}
