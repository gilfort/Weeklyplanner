// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_plan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weekPlanNotifierHash() => r'4cffc6ed040b6d5e49f36787af7d3d526ceb288d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$WeekPlanNotifier
    extends BuildlessAutoDisposeAsyncNotifier<WeekPlan> {
  late final String weekKey;

  FutureOr<WeekPlan> build(String weekKey);
}

/// See also [WeekPlanNotifier].
@ProviderFor(WeekPlanNotifier)
const weekPlanNotifierProvider = WeekPlanNotifierFamily();

/// See also [WeekPlanNotifier].
class WeekPlanNotifierFamily extends Family<AsyncValue<WeekPlan>> {
  /// See also [WeekPlanNotifier].
  const WeekPlanNotifierFamily();

  /// See also [WeekPlanNotifier].
  WeekPlanNotifierProvider call(String weekKey) {
    return WeekPlanNotifierProvider(weekKey);
  }

  @override
  WeekPlanNotifierProvider getProviderOverride(
    covariant WeekPlanNotifierProvider provider,
  ) {
    return call(provider.weekKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weekPlanNotifierProvider';
}

/// See also [WeekPlanNotifier].
class WeekPlanNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<WeekPlanNotifier, WeekPlan> {
  /// See also [WeekPlanNotifier].
  WeekPlanNotifierProvider(String weekKey)
    : this._internal(
        () => WeekPlanNotifier()..weekKey = weekKey,
        from: weekPlanNotifierProvider,
        name: r'weekPlanNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weekPlanNotifierHash,
        dependencies: WeekPlanNotifierFamily._dependencies,
        allTransitiveDependencies:
            WeekPlanNotifierFamily._allTransitiveDependencies,
        weekKey: weekKey,
      );

  WeekPlanNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.weekKey,
  }) : super.internal();

  final String weekKey;

  @override
  FutureOr<WeekPlan> runNotifierBuild(covariant WeekPlanNotifier notifier) {
    return notifier.build(weekKey);
  }

  @override
  Override overrideWith(WeekPlanNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: WeekPlanNotifierProvider._internal(
        () => create()..weekKey = weekKey,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        weekKey: weekKey,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<WeekPlanNotifier, WeekPlan>
  createElement() {
    return _WeekPlanNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekPlanNotifierProvider && other.weekKey == weekKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, weekKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeekPlanNotifierRef on AutoDisposeAsyncNotifierProviderRef<WeekPlan> {
  /// The parameter `weekKey` of this provider.
  String get weekKey;
}

class _WeekPlanNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<WeekPlanNotifier, WeekPlan>
    with WeekPlanNotifierRef {
  _WeekPlanNotifierProviderElement(super.provider);

  @override
  String get weekKey => (origin as WeekPlanNotifierProvider).weekKey;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
