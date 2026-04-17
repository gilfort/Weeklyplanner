// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncServiceHash() => r'aab0d6ff941082400210569168067c4fe5b9d4c3';

/// Creates and manages the [SyncService] when a [CachedSyncStorageBackend] is
/// active. Returns null for local/filesystem backends. Async because the
/// underlying storageBackendProvider is async (WebDAV credentials lookup).
///
/// Copied from [syncService].
@ProviderFor(syncService)
final syncServiceProvider = FutureProvider<SyncService?>.internal(
  syncService,
  name: r'syncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncServiceRef = FutureProviderRef<SyncService?>;
String _$syncStatusHash() => r'f7555df2192685e681e5eecaed71cb6d9b170dbe';

/// Exposes sync status as a stream for UI consumption.
///
/// Copied from [syncStatus].
@ProviderFor(syncStatus)
final syncStatusProvider = AutoDisposeStreamProvider<SyncStatusDetail>.internal(
  syncStatus,
  name: r'syncStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncStatusRef = AutoDisposeStreamProviderRef<SyncStatusDetail>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
