// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeekPlanImpl _$$WeekPlanImplFromJson(Map<String, dynamic> json) =>
    _$WeekPlanImpl(
      weekKey: json['weekKey'] as String,
      days:
          (json['days'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, DayPlan.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      quickAdds:
          (json['quickAdds'] as List<dynamic>?)
              ?.map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ShoppingItem>[],
      excludedGeneralIds:
          (json['excludedGeneralIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const <String>{},
      checkedKeys:
          (json['checkedKeys'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const <String>{},
      unavailableKeys:
          (json['unavailableKeys'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const <String>{},
      amountOverrides:
          (json['amountOverrides'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const <String, double>{},
    );

Map<String, dynamic> _$$WeekPlanImplToJson(_$WeekPlanImpl instance) =>
    <String, dynamic>{
      'weekKey': instance.weekKey,
      'days': instance.days.map((k, e) => MapEntry(k, e.toJson())),
      'quickAdds': instance.quickAdds.map((e) => e.toJson()).toList(),
      'excludedGeneralIds': instance.excludedGeneralIds.toList(),
      'checkedKeys': instance.checkedKeys.toList(),
      'unavailableKeys': instance.unavailableKeys.toList(),
      'amountOverrides': instance.amountOverrides,
    };
