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
  $Res call({String weekKey, Map<String, DayPlan> days});
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
  $Res call({Object? weekKey = null, Object? days = null}) {
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
  $Res call({String weekKey, Map<String, DayPlan> days});
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
  $Res call({Object? weekKey = null, Object? days = null}) {
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
  }) : _days = days;

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

  @override
  String toString() {
    return 'WeekPlan(weekKey: $weekKey, days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekPlanImpl &&
            (identical(other.weekKey, weekKey) || other.weekKey == weekKey) &&
            const DeepCollectionEquality().equals(other._days, _days));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    weekKey,
    const DeepCollectionEquality().hash(_days),
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
  }) = _$WeekPlanImpl;

  factory _WeekPlan.fromJson(Map<String, dynamic> json) =
      _$WeekPlanImpl.fromJson;

  /// Format: "2025-W14"
  @override
  String get weekKey;
  @override
  Map<String, DayPlan> get days;

  /// Create a copy of WeekPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeekPlanImplCopyWith<_$WeekPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
