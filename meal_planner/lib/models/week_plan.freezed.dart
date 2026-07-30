// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'week_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeekPlan _$WeekPlanFromJson(Map<String, dynamic> json) {
  return _WeekPlan.fromJson(json);
}

/// @nodoc
mixin _$WeekPlan {
  /// Format: "2025-W14"
  String get weekKey => throw _privateConstructorUsedError;
  Map<String, DayPlan> get days => throw _privateConstructorUsedError;

  /// Ad-hoc shopping items added via quick-add. Scoped to this week only.
  List<ShoppingItem> get quickAdds => throw _privateConstructorUsedError;

  /// IDs of GeneralItems hidden from this week's shopping list.
  /// Does not affect the underlying general items or recipe ingredients.
  Set<String> get excludedGeneralIds => throw _privateConstructorUsedError;

  /// Shopping-list items marked as bought (keyed by "name|unit", lowercase).
  Set<String> get checkedKeys => throw _privateConstructorUsedError;

  /// Shopping-list items marked as not available (keyed by "name|unit").
  Set<String> get unavailableKeys => throw _privateConstructorUsedError;

  /// Per-week amount override for shopping items (keyed by "name|unit").
  /// Replaces the derived amount; never mutates the recipe or general item.
  Map<String, double> get amountOverrides => throw _privateConstructorUsedError;

  /// Serializes this WeekPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeekPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeekPlanCopyWith<WeekPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeekPlanCopyWith<$Res> {
  factory $WeekPlanCopyWith(WeekPlan value, $Res Function(WeekPlan) then) =
      _$WeekPlanCopyWithImpl<$Res, WeekPlan>;
  @useResult
  $Res call({
    String weekKey,
    Map<String, DayPlan> days,
    List<ShoppingItem> quickAdds,
    Set<String> excludedGeneralIds,
    Set<String> checkedKeys,
    Set<String> unavailableKeys,
    Map<String, double> amountOverrides,
  });
}

/// @nodoc
class _$WeekPlanCopyWithImpl<$Res, $Val extends WeekPlan>
    implements $WeekPlanCopyWith<$Res> {
  _$WeekPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeekPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekKey = null,
    Object? days = null,
    Object? quickAdds = null,
    Object? excludedGeneralIds = null,
    Object? checkedKeys = null,
    Object? unavailableKeys = null,
    Object? amountOverrides = null,
  }) {
    return _then(
      _value.copyWith(
            weekKey: null == weekKey
                ? _value.weekKey
                : weekKey // ignore: cast_nullable_to_non_nullable
                      as String,
            days: null == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as Map<String, DayPlan>,
            quickAdds: null == quickAdds
                ? _value.quickAdds
                : quickAdds // ignore: cast_nullable_to_non_nullable
                      as List<ShoppingItem>,
            excludedGeneralIds: null == excludedGeneralIds
                ? _value.excludedGeneralIds
                : excludedGeneralIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            checkedKeys: null == checkedKeys
                ? _value.checkedKeys
                : checkedKeys // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            unavailableKeys: null == unavailableKeys
                ? _value.unavailableKeys
                : unavailableKeys // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            amountOverrides: null == amountOverrides
                ? _value.amountOverrides
                : amountOverrides // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeekPlanImplCopyWith<$Res>
    implements $WeekPlanCopyWith<$Res> {
  factory _$$WeekPlanImplCopyWith(
    _$WeekPlanImpl value,
    $Res Function(_$WeekPlanImpl) then,
  ) = __$$WeekPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String weekKey,
    Map<String, DayPlan> days,
    List<ShoppingItem> quickAdds,
    Set<String> excludedGeneralIds,
    Set<String> checkedKeys,
    Set<String> unavailableKeys,
    Map<String, double> amountOverrides,
  });
}

/// @nodoc
class __$$WeekPlanImplCopyWithImpl<$Res>
    extends _$WeekPlanCopyWithImpl<$Res, _$WeekPlanImpl>
    implements _$$WeekPlanImplCopyWith<$Res> {
  __$$WeekPlanImplCopyWithImpl(
    _$WeekPlanImpl _value,
    $Res Function(_$WeekPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeekPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekKey = null,
    Object? days = null,
    Object? quickAdds = null,
    Object? excludedGeneralIds = null,
    Object? checkedKeys = null,
    Object? unavailableKeys = null,
    Object? amountOverrides = null,
  }) {
    return _then(
      _$WeekPlanImpl(
        weekKey: null == weekKey
            ? _value.weekKey
            : weekKey // ignore: cast_nullable_to_non_nullable
                  as String,
        days: null == days
            ? _value._days
            : days // ignore: cast_nullable_to_non_nullable
                  as Map<String, DayPlan>,
        quickAdds: null == quickAdds
            ? _value._quickAdds
            : quickAdds // ignore: cast_nullable_to_non_nullable
                  as List<ShoppingItem>,
        excludedGeneralIds: null == excludedGeneralIds
            ? _value._excludedGeneralIds
            : excludedGeneralIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        checkedKeys: null == checkedKeys
            ? _value._checkedKeys
            : checkedKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        unavailableKeys: null == unavailableKeys
            ? _value._unavailableKeys
            : unavailableKeys // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        amountOverrides: null == amountOverrides
            ? _value._amountOverrides
            : amountOverrides // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeekPlanImpl implements _WeekPlan {
  const _$WeekPlanImpl({
    required this.weekKey,
    final Map<String, DayPlan> days = const {},
    final List<ShoppingItem> quickAdds = const <ShoppingItem>[],
    final Set<String> excludedGeneralIds = const <String>{},
    final Set<String> checkedKeys = const <String>{},
    final Set<String> unavailableKeys = const <String>{},
    final Map<String, double> amountOverrides = const <String, double>{},
  }) : _days = days,
       _quickAdds = quickAdds,
       _excludedGeneralIds = excludedGeneralIds,
       _checkedKeys = checkedKeys,
       _unavailableKeys = unavailableKeys,
       _amountOverrides = amountOverrides;

  factory _$WeekPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeekPlanImplFromJson(json);

  /// Format: "2025-W14"
  @override
  final String weekKey;
  final Map<String, DayPlan> _days;
  @override
  @JsonKey()
  Map<String, DayPlan> get days {
    if (_days is EqualUnmodifiableMapView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_days);
  }

  /// Ad-hoc shopping items added via quick-add. Scoped to this week only.
  final List<ShoppingItem> _quickAdds;

  /// Ad-hoc shopping items added via quick-add. Scoped to this week only.
  @override
  @JsonKey()
  List<ShoppingItem> get quickAdds {
    if (_quickAdds is EqualUnmodifiableListView) return _quickAdds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quickAdds);
  }

  /// IDs of GeneralItems hidden from this week's shopping list.
  /// Does not affect the underlying general items or recipe ingredients.
  final Set<String> _excludedGeneralIds;

  /// IDs of GeneralItems hidden from this week's shopping list.
  /// Does not affect the underlying general items or recipe ingredients.
  @override
  @JsonKey()
  Set<String> get excludedGeneralIds {
    if (_excludedGeneralIds is EqualUnmodifiableSetView)
      return _excludedGeneralIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_excludedGeneralIds);
  }

  /// Shopping-list items marked as bought (keyed by "name|unit", lowercase).
  final Set<String> _checkedKeys;

  /// Shopping-list items marked as bought (keyed by "name|unit", lowercase).
  @override
  @JsonKey()
  Set<String> get checkedKeys {
    if (_checkedKeys is EqualUnmodifiableSetView) return _checkedKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_checkedKeys);
  }

  /// Shopping-list items marked as not available (keyed by "name|unit").
  final Set<String> _unavailableKeys;

  /// Shopping-list items marked as not available (keyed by "name|unit").
  @override
  @JsonKey()
  Set<String> get unavailableKeys {
    if (_unavailableKeys is EqualUnmodifiableSetView) return _unavailableKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_unavailableKeys);
  }

  /// Per-week amount override for shopping items (keyed by "name|unit").
  /// Replaces the derived amount; never mutates the recipe or general item.
  final Map<String, double> _amountOverrides;

  /// Per-week amount override for shopping items (keyed by "name|unit").
  /// Replaces the derived amount; never mutates the recipe or general item.
  @override
  @JsonKey()
  Map<String, double> get amountOverrides {
    if (_amountOverrides is EqualUnmodifiableMapView) return _amountOverrides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_amountOverrides);
  }

  @override
  String toString() {
    return 'WeekPlan(weekKey: $weekKey, days: $days, quickAdds: $quickAdds, excludedGeneralIds: $excludedGeneralIds, checkedKeys: $checkedKeys, unavailableKeys: $unavailableKeys, amountOverrides: $amountOverrides)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekPlanImpl &&
            (identical(other.weekKey, weekKey) || other.weekKey == weekKey) &&
            const DeepCollectionEquality().equals(other._days, _days) &&
            const DeepCollectionEquality().equals(
              other._quickAdds,
              _quickAdds,
            ) &&
            const DeepCollectionEquality().equals(
              other._excludedGeneralIds,
              _excludedGeneralIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._checkedKeys,
              _checkedKeys,
            ) &&
            const DeepCollectionEquality().equals(
              other._unavailableKeys,
              _unavailableKeys,
            ) &&
            const DeepCollectionEquality().equals(
              other._amountOverrides,
              _amountOverrides,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    weekKey,
    const DeepCollectionEquality().hash(_days),
    const DeepCollectionEquality().hash(_quickAdds),
    const DeepCollectionEquality().hash(_excludedGeneralIds),
    const DeepCollectionEquality().hash(_checkedKeys),
    const DeepCollectionEquality().hash(_unavailableKeys),
    const DeepCollectionEquality().hash(_amountOverrides),
  );

  /// Create a copy of WeekPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeekPlanImplCopyWith<_$WeekPlanImpl> get copyWith =>
      __$$WeekPlanImplCopyWithImpl<_$WeekPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeekPlanImplToJson(this);
  }
}

abstract class _WeekPlan implements WeekPlan {
  const factory _WeekPlan({
    required final String weekKey,
    final Map<String, DayPlan> days,
    final List<ShoppingItem> quickAdds,
    final Set<String> excludedGeneralIds,
    final Set<String> checkedKeys,
    final Set<String> unavailableKeys,
    final Map<String, double> amountOverrides,
  }) = _$WeekPlanImpl;

  factory _WeekPlan.fromJson(Map<String, dynamic> json) =
      _$WeekPlanImpl.fromJson;

  /// Format: "2025-W14"
  @override
  String get weekKey;
  @override
  Map<String, DayPlan> get days;

  /// Ad-hoc shopping items added via quick-add. Scoped to this week only.
  @override
  List<ShoppingItem> get quickAdds;

  /// IDs of GeneralItems hidden from this week's shopping list.
  /// Does not affect the underlying general items or recipe ingredients.
  @override
  Set<String> get excludedGeneralIds;

  /// Shopping-list items marked as bought (keyed by "name|unit", lowercase).
  @override
  Set<String> get checkedKeys;

  /// Shopping-list items marked as not available (keyed by "name|unit").
  @override
  Set<String> get unavailableKeys;

  /// Per-week amount override for shopping items (keyed by "name|unit").
  /// Replaces the derived amount; never mutates the recipe or general item.
  @override
  Map<String, double> get amountOverrides;

  /// Create a copy of WeekPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeekPlanImplCopyWith<_$WeekPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
