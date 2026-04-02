// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_week_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentWeekKeyHash() => r'abd6d98f7cbb7490db65e76252583f210402abc4';

/// Returns the ISO week key for the current date, e.g. "2025-W14".
/// Kept as a simple provider so it can be overridden in tests.
///
/// Copied from [CurrentWeekKey].
@ProviderFor(CurrentWeekKey)
final currentWeekKeyProvider =
    AutoDisposeNotifierProvider<CurrentWeekKey, String>.internal(
      CurrentWeekKey.new,
      name: r'currentWeekKeyProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentWeekKeyHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentWeekKey = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
