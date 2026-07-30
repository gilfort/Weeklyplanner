// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentStorageModeHash() =>
    r'4a6908bd468547a43410b9c6816aa8ef5cfa96d8';

/// Persisted across launches via SharedPreferences.
///
/// Copied from [CurrentStorageMode].
@ProviderFor(CurrentStorageMode)
final currentStorageModeProvider =
    AsyncNotifierProvider<CurrentStorageMode, StorageMode>.internal(
      CurrentStorageMode.new,
      name: r'currentStorageModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentStorageModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentStorageMode = AsyncNotifier<StorageMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
