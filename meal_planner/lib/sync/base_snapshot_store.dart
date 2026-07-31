import '../repositories/storage_backend.dart';

/// Keeps a full copy of the last version this device and the sync target
/// agreed on, mirroring the entity layout under `.sync/`.
///
/// A hash per file would be far smaller, but a hash can only answer "did this
/// change" — it cannot serve as the base of a field-level merge. Without the
/// real content every genuine conflict would collapse to newest-wins and lose
/// one side's edits, which is the whole thing this rework exists to prevent.
///
/// It also removes the need for a dirty queue: "needs push" is simply
/// *current file ≠ snapshot*, derived from disk and therefore restart-safe.
class BaseSnapshotStore {
  /// Lives inside the app's private storage and is deliberately never synced;
  /// it describes *this* device's agreement with the target.
  static const dirName = '.sync';

  final StorageBackend storage;

  const BaseSnapshotStore(this.storage);

  String pathFor(String key) => '$dirName/$key';

  Future<String?> read(String key) => storage.read(pathFor(key));

  Future<void> write(String key, String content) =>
      storage.write(pathFor(key), content);

  Future<void> delete(String key) => storage.delete(pathFor(key));

  /// Snapshot file names for one entity directory.
  Future<List<String>> list(String dir) => storage.list('$dirName/$dir');
}
