// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_add_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuickAddItemImpl _$$QuickAddItemImplFromJson(Map<String, dynamic> json) =>
    _$QuickAddItemImpl(
      catalogId: json['catalogId'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? '',
    );

Map<String, dynamic> _$$QuickAddItemImplToJson(_$QuickAddItemImpl instance) =>
    <String, dynamic>{
      'catalogId': instance.catalogId,
      'amount': instance.amount,
      'unit': instance.unit,
    };
