// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quick_add_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuickAddItem _$QuickAddItemFromJson(Map<String, dynamic> json) {
  return _QuickAddItem.fromJson(json);
}

/// @nodoc
mixin _$QuickAddItem {
  String get catalogId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;

  /// Serializes this QuickAddItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuickAddItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuickAddItemCopyWith<QuickAddItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuickAddItemCopyWith<$Res> {
  factory $QuickAddItemCopyWith(
    QuickAddItem value,
    $Res Function(QuickAddItem) then,
  ) = _$QuickAddItemCopyWithImpl<$Res, QuickAddItem>;
  @useResult
  $Res call({String catalogId, double amount, String unit});
}

/// @nodoc
class _$QuickAddItemCopyWithImpl<$Res, $Val extends QuickAddItem>
    implements $QuickAddItemCopyWith<$Res> {
  _$QuickAddItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuickAddItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? catalogId = null,
    Object? amount = null,
    Object? unit = null,
  }) {
    return _then(
      _value.copyWith(
            catalogId: null == catalogId
                ? _value.catalogId
                : catalogId // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$QuickAddItemImplCopyWith<$Res>
    implements $QuickAddItemCopyWith<$Res> {
  factory _$$QuickAddItemImplCopyWith(
    _$QuickAddItemImpl value,
    $Res Function(_$QuickAddItemImpl) then,
  ) = __$$QuickAddItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String catalogId, double amount, String unit});
}

/// @nodoc
class __$$QuickAddItemImplCopyWithImpl<$Res>
    extends _$QuickAddItemCopyWithImpl<$Res, _$QuickAddItemImpl>
    implements _$$QuickAddItemImplCopyWith<$Res> {
  __$$QuickAddItemImplCopyWithImpl(
    _$QuickAddItemImpl _value,
    $Res Function(_$QuickAddItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuickAddItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? catalogId = null,
    Object? amount = null,
    Object? unit = null,
  }) {
    return _then(
      _$QuickAddItemImpl(
        catalogId: null == catalogId
            ? _value.catalogId
            : catalogId // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$QuickAddItemImpl implements _QuickAddItem {
  const _$QuickAddItemImpl({
    required this.catalogId,
    this.amount = 1.0,
    this.unit = '',
  });

  factory _$QuickAddItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuickAddItemImplFromJson(json);

  @override
  final String catalogId;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final String unit;

  @override
  String toString() {
    return 'QuickAddItem(catalogId: $catalogId, amount: $amount, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuickAddItemImpl &&
            (identical(other.catalogId, catalogId) ||
                other.catalogId == catalogId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, catalogId, amount, unit);

  /// Create a copy of QuickAddItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuickAddItemImplCopyWith<_$QuickAddItemImpl> get copyWith =>
      __$$QuickAddItemImplCopyWithImpl<_$QuickAddItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuickAddItemImplToJson(this);
  }
}

abstract class _QuickAddItem implements QuickAddItem {
  const factory _QuickAddItem({
    required final String catalogId,
    final double amount,
    final String unit,
  }) = _$QuickAddItemImpl;

  factory _QuickAddItem.fromJson(Map<String, dynamic> json) =
      _$QuickAddItemImpl.fromJson;

  @override
  String get catalogId;
  @override
  double get amount;
  @override
  String get unit;

  /// Create a copy of QuickAddItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuickAddItemImplCopyWith<_$QuickAddItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
