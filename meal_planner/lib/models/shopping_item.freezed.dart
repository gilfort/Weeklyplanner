// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShoppingItem _$ShoppingItemFromJson(Map<String, dynamic> json) {
  return _ShoppingItem.fromJson(json);
}

/// @nodoc
mixin _$ShoppingItem {
  String get catalogId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  List<ShoppingAmount> get amounts => throw _privateConstructorUsedError;
  ShoppingSource get source => throw _privateConstructorUsedError;

  /// True when a quick-add contributed to this line, which makes the line
  /// removable from the week without touching recipes or general items.
  bool get hasQuickAdd => throw _privateConstructorUsedError;

  /// Serializes this ShoppingItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShoppingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShoppingItemCopyWith<ShoppingItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShoppingItemCopyWith<$Res> {
  factory $ShoppingItemCopyWith(
    ShoppingItem value,
    $Res Function(ShoppingItem) then,
  ) = _$ShoppingItemCopyWithImpl<$Res, ShoppingItem>;
  @useResult
  $Res call({
    String catalogId,
    String name,
    String category,
    List<ShoppingAmount> amounts,
    ShoppingSource source,
    bool hasQuickAdd,
  });
}

/// @nodoc
class _$ShoppingItemCopyWithImpl<$Res, $Val extends ShoppingItem>
    implements $ShoppingItemCopyWith<$Res> {
  _$ShoppingItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShoppingItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? catalogId = null,
    Object? name = null,
    Object? category = null,
    Object? amounts = null,
    Object? source = null,
    Object? hasQuickAdd = null,
  }) {
    return _then(
      _value.copyWith(
            catalogId: null == catalogId
                ? _value.catalogId
                : catalogId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            amounts: null == amounts
                ? _value.amounts
                : amounts // ignore: cast_nullable_to_non_nullable
                      as List<ShoppingAmount>,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as ShoppingSource,
            hasQuickAdd: null == hasQuickAdd
                ? _value.hasQuickAdd
                : hasQuickAdd // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShoppingItemImplCopyWith<$Res>
    implements $ShoppingItemCopyWith<$Res> {
  factory _$$ShoppingItemImplCopyWith(
    _$ShoppingItemImpl value,
    $Res Function(_$ShoppingItemImpl) then,
  ) = __$$ShoppingItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String catalogId,
    String name,
    String category,
    List<ShoppingAmount> amounts,
    ShoppingSource source,
    bool hasQuickAdd,
  });
}

/// @nodoc
class __$$ShoppingItemImplCopyWithImpl<$Res>
    extends _$ShoppingItemCopyWithImpl<$Res, _$ShoppingItemImpl>
    implements _$$ShoppingItemImplCopyWith<$Res> {
  __$$ShoppingItemImplCopyWithImpl(
    _$ShoppingItemImpl _value,
    $Res Function(_$ShoppingItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShoppingItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? catalogId = null,
    Object? name = null,
    Object? category = null,
    Object? amounts = null,
    Object? source = null,
    Object? hasQuickAdd = null,
  }) {
    return _then(
      _$ShoppingItemImpl(
        catalogId: null == catalogId
            ? _value.catalogId
            : catalogId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        amounts: null == amounts
            ? _value._amounts
            : amounts // ignore: cast_nullable_to_non_nullable
                  as List<ShoppingAmount>,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as ShoppingSource,
        hasQuickAdd: null == hasQuickAdd
            ? _value.hasQuickAdd
            : hasQuickAdd // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShoppingItemImpl extends _ShoppingItem {
  const _$ShoppingItemImpl({
    required this.catalogId,
    required this.name,
    this.category = '',
    final List<ShoppingAmount> amounts = const <ShoppingAmount>[],
    this.source = ShoppingSource.general,
    this.hasQuickAdd = false,
  }) : _amounts = amounts,
       super._();

  factory _$ShoppingItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShoppingItemImplFromJson(json);

  @override
  final String catalogId;
  @override
  final String name;
  @override
  @JsonKey()
  final String category;
  final List<ShoppingAmount> _amounts;
  @override
  @JsonKey()
  List<ShoppingAmount> get amounts {
    if (_amounts is EqualUnmodifiableListView) return _amounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amounts);
  }

  @override
  @JsonKey()
  final ShoppingSource source;

  /// True when a quick-add contributed to this line, which makes the line
  /// removable from the week without touching recipes or general items.
  @override
  @JsonKey()
  final bool hasQuickAdd;

  @override
  String toString() {
    return 'ShoppingItem(catalogId: $catalogId, name: $name, category: $category, amounts: $amounts, source: $source, hasQuickAdd: $hasQuickAdd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShoppingItemImpl &&
            (identical(other.catalogId, catalogId) ||
                other.catalogId == catalogId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._amounts, _amounts) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.hasQuickAdd, hasQuickAdd) ||
                other.hasQuickAdd == hasQuickAdd));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    catalogId,
    name,
    category,
    const DeepCollectionEquality().hash(_amounts),
    source,
    hasQuickAdd,
  );

  /// Create a copy of ShoppingItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShoppingItemImplCopyWith<_$ShoppingItemImpl> get copyWith =>
      __$$ShoppingItemImplCopyWithImpl<_$ShoppingItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShoppingItemImplToJson(this);
  }
}

abstract class _ShoppingItem extends ShoppingItem {
  const factory _ShoppingItem({
    required final String catalogId,
    required final String name,
    final String category,
    final List<ShoppingAmount> amounts,
    final ShoppingSource source,
    final bool hasQuickAdd,
  }) = _$ShoppingItemImpl;
  const _ShoppingItem._() : super._();

  factory _ShoppingItem.fromJson(Map<String, dynamic> json) =
      _$ShoppingItemImpl.fromJson;

  @override
  String get catalogId;
  @override
  String get name;
  @override
  String get category;
  @override
  List<ShoppingAmount> get amounts;
  @override
  ShoppingSource get source;

  /// True when a quick-add contributed to this line, which makes the line
  /// removable from the week without touching recipes or general items.
  @override
  bool get hasQuickAdd;

  /// Create a copy of ShoppingItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShoppingItemImplCopyWith<_$ShoppingItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
