// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_path_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storagePathHash() => r'3ac6ac91cbbc883abb0715e029fcbc0290d94942';

/// Manages the user-configured storage directory path.
/// When `null`, the app uses the default documents directory.
///
/// Copied from [StoragePath].
@ProviderFor(StoragePath)
final storagePathProvider =
    AsyncNotifierProvider<StoragePath, String?>.internal(
      StoragePath.new,
      name: r'storagePathProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$storagePathHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StoragePath = AsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
