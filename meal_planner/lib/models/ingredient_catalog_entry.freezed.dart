// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_catalog_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

IngredientCatalogEntry _$IngredientCatalogEntryFromJson(
  Map<String, dynamic> json,
) {
  return _IngredientCatalogEntry.fromJson(json);
}

/// @nodoc
mixin _$IngredientCatalogEntry {
  String get id =>
      throw _privateConstructorUsedError; // lowercase name as stable key
  String get name => throw _privateConstructorUsedError;
  String get defaultUnit => throw _privateConstructorUsedError;
  String get defaultCategory => throw _privateConstructorUsedError;

  /// Serializes this IngredientCatalogEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IngredientCatalogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IngredientCatalogEntryCopyWith<IngredientCatalogEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientCatalogEntryCopyWith<$Res> {
  factory $IngredientCatalogEntryCopyWith(
    IngredientCatalogEntry value,
    $Res Function(IngredientCatalogEntry) then,
  ) = _$IngredientCatalogEntryCopyWithImpl<$Res, IngredientCatalogEntry>;
  @useResult
  $Res call({
    String id,
    String name,
    String defaultUnit,
    String defaultCategory,
  });
}

/// @nodoc
class _$IngredientCatalogEntryCopyWithImpl<
  $Res,
  $Val extends IngredientCatalogEntry
>
    implements $IngredientCatalogEntryCopyWith<$Res> {
  _$IngredientCatalogEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IngredientCatalogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? defaultUnit = null,
    Object? defaultCategory = null,
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
            defaultUnit: null == defaultUnit
                ? _value.defaultUnit
                : defaultUnit // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultCategory: null == defaultCategory
                ? _value.defaultCategory
                : defaultCategory // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IngredientCatalogEntryImplCopyWith<$Res>
    implements $IngredientCatalogEntryCopyWith<$Res> {
  factory _$$IngredientCatalogEntryImplCopyWith(
    _$IngredientCatalogEntryImpl value,
    $Res Function(_$IngredientCatalogEntryImpl) then,
  ) = __$$IngredientCatalogEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String defaultUnit,
    String defaultCategory,
  });
}

/// @nodoc
class __$$IngredientCatalogEntryImplCopyWithImpl<$Res>
    extends
        _$IngredientCatalogEntryCopyWithImpl<$Res, _$IngredientCatalogEntryImpl>
    implements _$$IngredientCatalogEntryImplCopyWith<$Res> {
  __$$IngredientCatalogEntryImplCopyWithImpl(
    _$IngredientCatalogEntryImpl _value,
    $Res Function(_$IngredientCatalogEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IngredientCatalogEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? defaultUnit = null,
    Object? defaultCategory = null,
  }) {
    return _then(
      _$IngredientCatalogEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultUnit: null == defaultUnit
            ? _value.defaultUnit
            : defaultUnit // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultCategory: null == defaultCategory
            ? _value.defaultCategory
            : defaultCategory // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientCatalogEntryImpl implements _IngredientCatalogEntry {
  const _$IngredientCatalogEntryImpl({
    required this.id,
    required this.name,
    this.defaultUnit = '',
    this.defaultCategory = '',
  });

  factory _$IngredientCatalogEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientCatalogEntryImplFromJson(json);

  @override
  final String id;
  // lowercase name as stable key
  @override
  final String name;
  @override
  @JsonKey()
  final String defaultUnit;
  @override
  @JsonKey()
  final String defaultCategory;

  @override
  String toString() {
    return 'IngredientCatalogEntry(id: $id, name: $name, defaultUnit: $defaultUnit, defaultCategory: $defaultCategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientCatalogEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.defaultUnit, defaultUnit) ||
                other.defaultUnit == defaultUnit) &&
            (identical(other.defaultCategory, defaultCategory) ||
                other.defaultCategory == defaultCategory));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, defaultUnit, defaultCategory);

  /// Create a copy of IngredientCatalogEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientCatalogEntryImplCopyWith<_$IngredientCatalogEntryImpl>
  get copyWith =>
      __$$IngredientCatalogEntryImplCopyWithImpl<_$IngredientCatalogEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientCatalogEntryImplToJson(this);
  }
}

abstract class _IngredientCatalogEntry implements IngredientCatalogEntry {
  const factory _IngredientCatalogEntry({
    required final String id,
    required final String name,
    final String defaultUnit,
    final String defaultCategory,
  }) = _$IngredientCatalogEntryImpl;

  factory _IngredientCatalogEntry.fromJson(Map<String, dynamic> json) =
      _$IngredientCatalogEntryImpl.fromJson;

  @override
  String get id; // lowercase name as stable key
  @override
  String get name;
  @override
  String get defaultUnit;
  @override
  String get defaultCategory;

  /// Create a copy of IngredientCatalogEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IngredientCatalogEntryImplCopyWith<_$IngredientCatalogEntryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
