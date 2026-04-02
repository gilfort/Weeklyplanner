// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MealSlot _$MealSlotFromJson(Map<String, dynamic> json) {
  return _MealSlot.fromJson(json);
}

/// @nodoc
mixin _$MealSlot {
  String? get recipeId => throw _privateConstructorUsedError;
  int? get servings => throw _privateConstructorUsedError;
  bool get done => throw _privateConstructorUsedError;

  /// Serializes this MealSlot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealSlotCopyWith<MealSlot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealSlotCopyWith<$Res> {
  factory $MealSlotCopyWith(MealSlot value, $Res Function(MealSlot) then) =
      _$MealSlotCopyWithImpl<$Res, MealSlot>;
  @useResult
  $Res call({String? recipeId, int? servings, bool done});
}

/// @nodoc
class _$MealSlotCopyWithImpl<$Res, $Val extends MealSlot>
    implements $MealSlotCopyWith<$Res> {
  _$MealSlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipeId = freezed,
    Object? servings = freezed,
    Object? done = null,
  }) {
    return _then(
      _value.copyWith(
            recipeId: freezed == recipeId
                ? _value.recipeId
                : recipeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            servings: freezed == servings
                ? _value.servings
                : servings // ignore: cast_nullable_to_non_nullable
                      as int?,
            done: null == done
                ? _value.done
                : done // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealSlotImplCopyWith<$Res>
    implements $MealSlotCopyWith<$Res> {
  factory _$$MealSlotImplCopyWith(
    _$MealSlotImpl value,
    $Res Function(_$MealSlotImpl) then,
  ) = __$$MealSlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? recipeId, int? servings, bool done});
}

/// @nodoc
class __$$MealSlotImplCopyWithImpl<$Res>
    extends _$MealSlotCopyWithImpl<$Res, _$MealSlotImpl>
    implements _$$MealSlotImplCopyWith<$Res> {
  __$$MealSlotImplCopyWithImpl(
    _$MealSlotImpl _value,
    $Res Function(_$MealSlotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipeId = freezed,
    Object? servings = freezed,
    Object? done = null,
  }) {
    return _then(
      _$MealSlotImpl(
        recipeId: freezed == recipeId
            ? _value.recipeId
            : recipeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        servings: freezed == servings
            ? _value.servings
            : servings // ignore: cast_nullable_to_non_nullable
                  as int?,
        done: null == done
            ? _value.done
            : done // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealSlotImpl implements _MealSlot {
  const _$MealSlotImpl({this.recipeId, this.servings, this.done = false});

  factory _$MealSlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealSlotImplFromJson(json);

  @override
  final String? recipeId;
  @override
  final int? servings;
  @override
  @JsonKey()
  final bool done;

  @override
  String toString() {
    return 'MealSlot(recipeId: $recipeId, servings: $servings, done: $done)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealSlotImpl &&
            (identical(other.recipeId, recipeId) ||
                other.recipeId == recipeId) &&
            (identical(other.servings, servings) ||
                other.servings == servings) &&
            (identical(other.done, done) || other.done == done));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, recipeId, servings, done);

  /// Create a copy of MealSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealSlotImplCopyWith<_$MealSlotImpl> get copyWith =>
      __$$MealSlotImplCopyWithImpl<_$MealSlotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealSlotImplToJson(this);
  }
}

abstract class _MealSlot implements MealSlot {
  const factory _MealSlot({
    final String? recipeId,
    final int? servings,
    final bool done,
  }) = _$MealSlotImpl;

  factory _MealSlot.fromJson(Map<String, dynamic> json) =
      _$MealSlotImpl.fromJson;

  @override
  String? get recipeId;
  @override
  int? get servings;
  @override
  bool get done;

  /// Create a copy of MealSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealSlotImplCopyWith<_$MealSlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
