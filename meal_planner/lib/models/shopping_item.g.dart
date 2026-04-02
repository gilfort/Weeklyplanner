// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShoppingItemImpl _$$ShoppingItemImplFromJson(Map<String, dynamic> json) =>
    _$ShoppingItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isChecked: json['isChecked'] as bool? ?? false,
      isUnavailable: json['isUnavailable'] as bool? ?? false,
      source:
          $enumDecodeNullable(_$ShoppingSourceEnumMap, json['source']) ??
          ShoppingSource.general,
    );

Map<String, dynamic> _$$ShoppingItemImplToJson(_$ShoppingItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'unit': instance.unit,
      'category': instance.category,
      'isChecked': instance.isChecked,
      'isUnavailable': instance.isUnavailable,
      'source': _$ShoppingSourceEnumMap[instance.source]!,
    };

const _$ShoppingSourceEnumMap = {
  ShoppingSource.recipe: 'recipe',
  ShoppingSource.general: 'general',
  ShoppingSource.merged: 'merged',
};
