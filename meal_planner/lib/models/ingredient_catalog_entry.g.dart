// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_catalog_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IngredientCatalogEntryImpl _$$IngredientCatalogEntryImplFromJson(
  Map<String, dynamic> json,
) => _$IngredientCatalogEntryImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  defaultUnit: json['defaultUnit'] as String? ?? '',
  defaultCategory: json['defaultCategory'] as String? ?? '',
  deleted: json['deleted'] as bool? ?? false,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$$IngredientCatalogEntryImplToJson(
  _$IngredientCatalogEntryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'defaultUnit': instance.defaultUnit,
  'defaultCategory': instance.defaultCategory,
  'deleted': instance.deleted,
  'deletedAt': instance.deletedAt?.toIso8601String(),
};
