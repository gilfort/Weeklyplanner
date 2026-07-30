// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_amount.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShoppingAmount _$ShoppingAmountFromJson(Map<String, dynamic> json) {
  return _ShoppingAmount.fromJson(json);
}

/// @nodoc
mixin _$ShoppingAmount {
  double get amount => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;

  /// Serializes this ShoppingAmount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShoppingAmount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShoppingAmountCopyWith<ShoppingAmount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShoppingAmountCopyWith<$Res> {
  factory $ShoppingAmountCopyWith(
    ShoppingAmount value,
    $Res Function(ShoppingAmount) then,
  ) = _$ShoppingAmountCopyWithImpl<$Res, ShoppingAmount>;
  @useResult
  $Res call({double amount, String unit});
}

/// @nodoc
class _$ShoppingAmountCopyWithImpl<$Res, $Val extends ShoppingAmount>
    implements $ShoppingAmountCopyWith<$Res> {
  _$ShoppingAmountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShoppingAmount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? amount = null, Object? unit = null}) {
    return _then(
      _value.copyWith(
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShoppingAmountImplCopyWith<$Res>
    implements $ShoppingAmountCopyWith<$Res> {
  factory _$$ShoppingAmountImplCopyWith(
    _$ShoppingAmountImpl value,
    $Res Function(_$ShoppingAmountImpl) then,
  ) = __$$ShoppingAmountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double amount, String unit});
}

/// @nodoc
class __$$ShoppingAmountImplCopyWithImpl<$Res>
    extends _$ShoppingAmountCopyWithImpl<$Res, _$ShoppingAmountImpl>
    implements _$$ShoppingAmountImplCopyWith<$Res> {
  __$$ShoppingAmountImplCopyWithImpl(
    _$ShoppingAmountImpl _value,
    $Res Function(_$ShoppingAmountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShoppingAmount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? amount = null, Object? unit = null}) {
    return _then(
      _$ShoppingAmountImpl(
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShoppingAmountImpl implements _ShoppingAmount {
  const _$ShoppingAmountImpl({required this.amount, this.unit = ''});

  factory _$ShoppingAmountImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShoppingAmountImplFromJson(json);

  @override
  final double amount;
  @override
  @JsonKey()
  final String unit;

  @override
  String toString() {
    return 'ShoppingAmount(amount: $amount, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShoppingAmountImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, amount, unit);

  /// Create a copy of ShoppingAmount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShoppingAmountImplCopyWith<_$ShoppingAmountImpl> get copyWith =>
      __$$ShoppingAmountImplCopyWithImpl<_$ShoppingAmountImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ShoppingAmountImplToJson(this);
  }
}

abstract class _ShoppingAmount implements ShoppingAmount {
  const factory _ShoppingAmount({
    required final double amount,
    final String unit,
  }) = _$ShoppingAmountImpl;

  factory _ShoppingAmount.fromJson(Map<String, dynamic> json) =
      _$ShoppingAmountImpl.fromJson;

  @override
  double get amount;
  @override
  String get unit;

  /// Create a copy of ShoppingAmount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShoppingAmountImplCopyWith<_$ShoppingAmountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
