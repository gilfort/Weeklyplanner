// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShoppingItemImpl _$$ShoppingItemImplFromJson(Map<String, dynamic> json) =>
    _$ShoppingItemImpl(
      catalogId: json['catalogId'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? '',
      amounts:
          (json['amounts'] as List<dynamic>?)
              ?.map((e) => ShoppingAmount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ShoppingAmount>[],
      source:
          $enumDecodeNullable(_$ShoppingSourceEnumMap, json['source']) ??
          ShoppingSource.general,
      hasQuickAdd: json['hasQuickAdd'] as bool? ?? false,
    );

Map<String, dynamic> _$$ShoppingItemImplToJson(_$ShoppingItemImpl instance) =>
    <String, dynamic>{
      'catalogId': instance.catalogId,
      'name': instance.name,
      'category': instance.category,
      'amounts': instance.amounts.map((e) => e.toJson()).toList(),
      'source': _$ShoppingSourceEnumMap[instance.source]!,
      'hasQuickAdd': instance.hasQuickAdd,
    };

const _$ShoppingSourceEnumMap = {
  ShoppingSource.recipe: 'recipe',
  ShoppingSource.general: 'general',
  ShoppingSource.merged: 'merged',
};
