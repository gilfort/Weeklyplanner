// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GeneralItemImpl _$$GeneralItemImplFromJson(Map<String, dynamic> json) =>
    _$GeneralItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? '',
      category: json['category'] as String? ?? '',
      excludedThisTrip: json['excludedThisTrip'] as bool? ?? false,
    );

Map<String, dynamic> _$$GeneralItemImplToJson(_$GeneralItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'unit': instance.unit,
      'category': instance.category,
      'excludedThisTrip': instance.excludedThisTrip,
    };
