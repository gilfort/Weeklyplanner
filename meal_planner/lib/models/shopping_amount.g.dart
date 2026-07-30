// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_amount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShoppingAmountImpl _$$ShoppingAmountImplFromJson(Map<String, dynamic> json) =>
    _$ShoppingAmountImpl(
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String? ?? '',
    );

Map<String, dynamic> _$$ShoppingAmountImplToJson(
  _$ShoppingAmountImpl instance,
) => <String, dynamic>{'amount': instance.amount, 'unit': instance.unit};
