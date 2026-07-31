// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncServiceHash() => r'38a364b222b424fc8b31182136c745be76d9085a';

/// Creates and manages the [SyncService] for whichever target is configured.
/// Returns null when there is nothing to sync with (local-only storage).
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
String _$syncStatusHash() => r'8903b48d7b883f7f27b5df27a0e79778c3380b3b';

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
