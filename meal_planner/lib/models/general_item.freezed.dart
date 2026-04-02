// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'general_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GeneralItem _$GeneralItemFromJson(Map<String, dynamic> json) {
  return _GeneralItem.fromJson(json);
}

/// @nodoc
mixin _$GeneralItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;

  /// Serializes this GeneralItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeneralItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeneralItemCopyWith<GeneralItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeneralItemCopyWith<$Res> {
  factory $GeneralItemCopyWith(
    GeneralItem value,
    $Res Function(GeneralItem) then,
  ) = _$GeneralItemCopyWithImpl<$Res, GeneralItem>;
  @useResult
  $Res call({
    String id,
    String name,
    double amount,
    String unit,
    String category,
  });
}

/// @nodoc
class _$GeneralItemCopyWithImpl<$Res, $Val extends GeneralItem>
    implements $GeneralItemCopyWith<$Res> {
  _$GeneralItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeneralItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amount = null,
    Object? unit = null,
    Object? category = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GeneralItemImplCopyWith<$Res>
    implements $GeneralItemCopyWith<$Res> {
  factory _$$GeneralItemImplCopyWith(
    _$GeneralItemImpl value,
    $Res Function(_$GeneralItemImpl) then,
  ) = __$$GeneralItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    double amount,
    String unit,
    String category,
  });
}

/// @nodoc
class __$$GeneralItemImplCopyWithImpl<$Res>
    extends _$GeneralItemCopyWithImpl<$Res, _$GeneralItemImpl>
    implements _$$GeneralItemImplCopyWith<$Res> {
  __$$GeneralItemImplCopyWithImpl(
    _$GeneralItemImpl _value,
    $Res Function(_$GeneralItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GeneralItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amount = null,
    Object? unit = null,
    Object? category = null,
  }) {
    return _then(
      _$GeneralItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GeneralItemImpl implements _GeneralItem {
  const _$GeneralItemImpl({
    required this.id,
    required this.name,
    this.amount = 1.0,
    this.unit = '',
    this.category = '',
  });

  factory _$GeneralItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeneralItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final String unit;
  @override
  @JsonKey()
  final String category;

  @override
  String toString() {
    return 'GeneralItem(id: $id, name: $name, amount: $amount, unit: $unit, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneralItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, amount, unit, category);

  /// Create a copy of GeneralItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneralItemImplCopyWith<_$GeneralItemImpl> get copyWith =>
      __$$GeneralItemImplCopyWithImpl<_$GeneralItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeneralItemImplToJson(this);
  }
}

abstract class _GeneralItem implements GeneralItem {
  const factory _GeneralItem({
    required final String id,
    required final String name,
    final double amount,
    final String unit,
    final String category,
  }) = _$GeneralItemImpl;

  factory _GeneralItem.fromJson(Map<String, dynamic> json) =
      _$GeneralItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get amount;
  @override
  String get unit;
  @override
  String get category;

  /// Create a copy of GeneralItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeneralItemImplCopyWith<_$GeneralItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
