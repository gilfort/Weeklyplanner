// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IngredientImpl _$$IngredientImplFromJson(Map<String, dynamic> json) =>
    _$IngredientImpl(
      catalogId: json['catalogId'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String? ?? '',
    );

Map<String, dynamic> _$$IngredientImplToJson(_$IngredientImpl instance) =>
    <String, dynamic>{
      'catalogId': instance.catalogId,
      'amount': instance.amount,
      'unit': instance.unit,
    };
