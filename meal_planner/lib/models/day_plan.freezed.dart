// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DayPlan _$DayPlanFromJson(Map<String, dynamic> json) {
  return _DayPlan.fromJson(json);
}

/// @nodoc
mixin _$DayPlan {
  MealSlot? get morning => throw _privateConstructorUsedError;
  MealSlot? get lunch => throw _privateConstructorUsedError;
  MealSlot? get dinner => throw _privateConstructorUsedError;
  MealSlot? get snack => throw _privateConstructorUsedError;

  /// Serializes this DayPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DayPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayPlanCopyWith<DayPlan> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayPlanCopyWith<$Res> {
  factory $DayPlanCopyWith(DayPlan value, $Res Function(DayPlan) then) =
      _$DayPlanCopyWithImpl<$Res, DayPlan>;
  @useResult
  $Res call({
    MealSlot? morning,
    MealSlot? lunch,
    MealSlot? dinner,
    MealSlot? snack,
  });

  $MealSlotCopyWith<$Res>? get morning;
  $MealSlotCopyWith<$Res>? get lunch;
  $MealSlotCopyWith<$Res>? get dinner;
  $MealSlotCopyWith<$Res>? get snack;
}

/// @nodoc
class _$DayPlanCopyWithImpl<$Res, $Val extends DayPlan>
    implements $DayPlanCopyWith<$Res> {
  _$DayPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DayPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? morning = freezed,
    Object? lunch = freezed,
    Object? dinner = freezed,
    Object? snack = freezed,
  }) {
    return _then(
      _value.copyWith(
            morning: freezed == morning
                ? _value.morning
                : morning // ignore: cast_nullable_to_non_nullable
                      as MealSlot?,
            lunch: freezed == lunch
                ? _value.lunch
                : lunch // ignore: cast_nullable_to_non_nullable
                      as MealSlot?,
            dinner: freezed == dinner
                ? _value.dinner
                : dinner // ignore: cast_nullable_to_non_nullable
                      as MealSlot?,
            snack: freezed == snack
                ? _value.snack
                : snack // ignore: cast_nullable_to_non_nullable
                      as MealSlot?,
          )
          as $Val,
    );
  }

  /// Create a copy of DayPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealSlotCopyWith<$Res>? get morning {
    if (_value.morning == null) {
      return null;
    }

    return $MealSlotCopyWith<$Res>(_value.morning!, (value) {
      return _then(_value.copyWith(morning: value) as $Val);
    });
  }

  /// Create a copy of DayPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealSlotCopyWith<$Res>? get lunch {
    if (_value.lunch == null) {
      return null;
    }

    return $MealSlotCopyWith<$Res>(_value.lunch!, (value) {
      return _then(_value.copyWith(lunch: value) as $Val);
    });
  }

  /// Create a copy of DayPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealSlotCopyWith<$Res>? get dinner {
    if (_value.dinner == null) {
      return null;
    }

    return $MealSlotCopyWith<$Res>(_value.dinner!, (value) {
      return _then(_value.copyWith(dinner: value) as $Val);
    });
  }

  /// Create a copy of DayPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealSlotCopyWith<$Res>? get snack {
    if (_value.snack == null) {
      return null;
    }

    return $MealSlotCopyWith<$Res>(_value.snack!, (value) {
      return _then(_value.copyWith(snack: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DayPlanImplCopyWith<$Res> implements $DayPlanCopyWith<$Res> {
  factory _$$DayPlanImplCopyWith(
    _$DayPlanImpl value,
    $Res Function(_$DayPlanImpl) then,
  ) = __$$DayPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MealSlot? morning,
    MealSlot? lunch,
    MealSlot? dinner,
    MealSlot? snack,
  });

  @override
  $MealSlotCopyWith<$Res>? get morning;
  @override
  $MealSlotCopyWith<$Res>? get lunch;
  @override
  $MealSlotCopyWith<$Res>? get dinner;
  @override
  $MealSlotCopyWith<$Res>? get snack;
}

/// @nodoc
class __$$DayPlanImplCopyWithImpl<$Res>
    extends _$DayPlanCopyWithImpl<$Res, _$DayPlanImpl>
    implements _$$DayPlanImplCopyWith<$Res> {
  __$$DayPlanImplCopyWithImpl(
    _$DayPlanImpl _value,
    $Res Function(_$DayPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DayPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? morning = freezed,
    Object? lunch = freezed,
    Object? dinner = freezed,
    Object? snack = freezed,
  }) {
    return _then(
      _$DayPlanImpl(
        morning: freezed == morning
            ? _value.morning
            : morning // ignore: cast_nullable_to_non_nullable
                  as MealSlot?,
        lunch: freezed == lunch
            ? _value.lunch
            : lunch // ignore: cast_nullable_to_non_nullable
                  as MealSlot?,
        dinner: freezed == dinner
            ? _value.dinner
            : dinner // ignore: cast_nullable_to_non_nullable
                  as MealSlot?,
        snack: freezed == snack
            ? _value.snack
            : snack // ignore: cast_nullable_to_non_nullable
                  as MealSlot?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DayPlanImpl implements _DayPlan {
  const _$DayPlanImpl({this.morning, this.lunch, this.dinner, this.snack});

  factory _$DayPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$DayPlanImplFromJson(json);

  @override
  final MealSlot? morning;
  @override
  final MealSlot? lunch;
  @override
  final MealSlot? dinner;
  @override
  final MealSlot? snack;

  @override
  String toString() {
    return 'DayPlan(morning: $morning, lunch: $lunch, dinner: $dinner, snack: $snack)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayPlanImpl &&
            (identical(other.morning, morning) || other.morning == morning) &&
            (identical(other.lunch, lunch) || other.lunch == lunch) &&
            (identical(other.dinner, dinner) || other.dinner == dinner) &&
            (identical(other.snack, snack) || other.snack == snack));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, morning, lunch, dinner, snack);

  /// Create a copy of DayPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayPlanImplCopyWith<_$DayPlanImpl> get copyWith =>
      __$$DayPlanImplCopyWithImpl<_$DayPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DayPlanImplToJson(this);
  }
}

abstract class _DayPlan implements DayPlan {
  const factory _DayPlan({
    final MealSlot? morning,
    final MealSlot? lunch,
    final MealSlot? dinner,
    final MealSlot? snack,
  }) = _$DayPlanImpl;

  factory _DayPlan.fromJson(Map<String, dynamic> json) = _$DayPlanImpl.fromJson;

  @override
  MealSlot? get morning;
  @override
  MealSlot? get lunch;
  @override
  MealSlot? get dinner;
  @override
  MealSlot? get snack;

  /// Create a copy of DayPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayPlanImplCopyWith<_$DayPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
