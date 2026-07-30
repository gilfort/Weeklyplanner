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
  List<QuickAddItem> get quickAdds => throw _privateConstructorUsedError;

  /// Catalog ids of general items hidden from this week's shopping list.
  /// Does not affect the underlying general items or recipe ingredients.
  Set<String> get excludedGeneralIds => throw _privateConstructorUsedError;

  /// Catalog ids of shopping lines marked as bought.
  Set<String> get checkedIds => throw _privateConstructorUsedError;

  /// Catalog ids of shopping lines marked as not available.
  Set<String> get unavailableIds => throw _privateConstructorUsedError;

  /// Per-week amount override for a shopping line, keyed by catalog id.
  /// Replaces the derived amounts entirely (one amount in one unit);
  /// never mutates the recipe, general item or catalog entry.
  Map<String, ShoppingAmount> get amountOverrides =>
      throw _privateConstructorUsedError;
  bool get deleted => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

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
    List<QuickAddItem> quickAdds,
    Set<String> excludedGeneralIds,
    Set<String> checkedIds,
    Set<String> unavailableIds,
    Map<String, ShoppingAmount> amountOverrides,
    bool deleted,
    DateTime? deletedAt,
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
    Object? checkedIds = null,
    Object? unavailableIds = null,
    Object? amountOverrides = null,
    Object? deleted = null,
    Object? deletedAt = freezed,
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
                      as List<QuickAddItem>,
            excludedGeneralIds: null == excludedGeneralIds
                ? _value.excludedGeneralIds
                : excludedGeneralIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            checkedIds: null == checkedIds
                ? _value.checkedIds
                : checkedIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            unavailableIds: null == unavailableIds
                ? _value.unavailableIds
                : unavailableIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            amountOverrides: null == amountOverrides
                ? _value.amountOverrides
                : amountOverrides // ignore: cast_nullable_to_non_nullable
                      as Map<String, ShoppingAmount>,
            deleted: null == deleted
                ? _value.deleted
                : deleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
    List<QuickAddItem> quickAdds,
    Set<String> excludedGeneralIds,
    Set<String> checkedIds,
    Set<String> unavailableIds,
    Map<String, ShoppingAmount> amountOverrides,
    bool deleted,
    DateTime? deletedAt,
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
    Object? checkedIds = null,
    Object? unavailableIds = null,
    Object? amountOverrides = null,
    Object? deleted = null,
    Object? deletedAt = freezed,
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
                  as List<QuickAddItem>,
        excludedGeneralIds: null == excludedGeneralIds
            ? _value._excludedGeneralIds
            : excludedGeneralIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        checkedIds: null == checkedIds
            ? _value._checkedIds
            : checkedIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        unavailableIds: null == unavailableIds
            ? _value._unavailableIds
            : unavailableIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        amountOverrides: null == amountOverrides
            ? _value._amountOverrides
            : amountOverrides // ignore: cast_nullable_to_non_nullable
                  as Map<String, ShoppingAmount>,
        deleted: null == deleted
            ? _value.deleted
            : deleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
    final List<QuickAddItem> quickAdds = const <QuickAddItem>[],
    final Set<String> excludedGeneralIds = const <String>{},
    final Set<String> checkedIds = const <String>{},
    final Set<String> unavailableIds = const <String>{},
    final Map<String, ShoppingAmount> amountOverrides =
        const <String, ShoppingAmount>{},
    this.deleted = false,
    this.deletedAt,
  }) : _days = days,
       _quickAdds = quickAdds,
       _excludedGeneralIds = excludedGeneralIds,
       _checkedIds = checkedIds,
       _unavailableIds = unavailableIds,
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
  final List<QuickAddItem> _quickAdds;

  /// Ad-hoc shopping items added via quick-add. Scoped to this week only.
  @override
  @JsonKey()
  List<QuickAddItem> get quickAdds {
    if (_quickAdds is EqualUnmodifiableListView) return _quickAdds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quickAdds);
  }

  /// Catalog ids of general items hidden from this week's shopping list.
  /// Does not affect the underlying general items or recipe ingredients.
  final Set<String> _excludedGeneralIds;

  /// Catalog ids of general items hidden from this week's shopping list.
  /// Does not affect the underlying general items or recipe ingredients.
  @override
  @JsonKey()
  Set<String> get excludedGeneralIds {
    if (_excludedGeneralIds is EqualUnmodifiableSetView)
      return _excludedGeneralIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_excludedGeneralIds);
  }

  /// Catalog ids of shopping lines marked as bought.
  final Set<String> _checkedIds;

  /// Catalog ids of shopping lines marked as bought.
  @override
  @JsonKey()
  Set<String> get checkedIds {
    if (_checkedIds is EqualUnmodifiableSetView) return _checkedIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_checkedIds);
  }

  /// Catalog ids of shopping lines marked as not available.
  final Set<String> _unavailableIds;

  /// Catalog ids of shopping lines marked as not available.
  @override
  @JsonKey()
  Set<String> get unavailableIds {
    if (_unavailableIds is EqualUnmodifiableSetView) return _unavailableIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_unavailableIds);
  }

  /// Per-week amount override for a shopping line, keyed by catalog id.
  /// Replaces the derived amounts entirely (one amount in one unit);
  /// never mutates the recipe, general item or catalog entry.
  final Map<String, ShoppingAmount> _amountOverrides;

  /// Per-week amount override for a shopping line, keyed by catalog id.
  /// Replaces the derived amounts entirely (one amount in one unit);
  /// never mutates the recipe, general item or catalog entry.
  @override
  @JsonKey()
  Map<String, ShoppingAmount> get amountOverrides {
    if (_amountOverrides is EqualUnmodifiableMapView) return _amountOverrides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_amountOverrides);
  }

  @override
  @JsonKey()
  final bool deleted;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'WeekPlan(weekKey: $weekKey, days: $days, quickAdds: $quickAdds, excludedGeneralIds: $excludedGeneralIds, checkedIds: $checkedIds, unavailableIds: $unavailableIds, amountOverrides: $amountOverrides, deleted: $deleted, deletedAt: $deletedAt)';
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
              other._checkedIds,
              _checkedIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._unavailableIds,
              _unavailableIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._amountOverrides,
              _amountOverrides,
            ) &&
            (identical(other.deleted, deleted) || other.deleted == deleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    weekKey,
    const DeepCollectionEquality().hash(_days),
    const DeepCollectionEquality().hash(_quickAdds),
    const DeepCollectionEquality().hash(_excludedGeneralIds),
    const DeepCollectionEquality().hash(_checkedIds),
    const DeepCollectionEquality().hash(_unavailableIds),
    const DeepCollectionEquality().hash(_amountOverrides),
    deleted,
    deletedAt,
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
    final List<QuickAddItem> quickAdds,
    final Set<String> excludedGeneralIds,
    final Set<String> checkedIds,
    final Set<String> unavailableIds,
    final Map<String, ShoppingAmount> amountOverrides,
    final bool deleted,
    final DateTime? deletedAt,
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
  List<QuickAddItem> get quickAdds;

  /// Catalog ids of general items hidden from this week's shopping list.
  /// Does not affect the underlying general items or recipe ingredients.
  @override
  Set<String> get excludedGeneralIds;

  /// Catalog ids of shopping lines marked as bought.
  @override
  Set<String> get checkedIds;

  /// Catalog ids of shopping lines marked as not available.
  @override
  Set<String> get unavailableIds;

  /// Per-week amount override for a shopping line, keyed by catalog id.
  /// Replaces the derived amounts entirely (one amount in one unit);
  /// never mutates the recipe, general item or catalog entry.
  @override
  Map<String, ShoppingAmount> get amountOverrides;
  @override
  bool get deleted;
  @override
  DateTime? get deletedAt;

  /// Create a copy of WeekPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeekPlanImplCopyWith<_$WeekPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
