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
              ?.map((e) => QuickAddItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <QuickAddItem>[],
      excludedGeneralIds:
          (json['excludedGeneralIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const <String>{},
      checkedIds:
          (json['checkedIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const <String>{},
      unavailableIds:
          (json['unavailableIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const <String>{},
      amountOverrides:
          (json['amountOverrides'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, ShoppingAmount.fromJson(e as Map<String, dynamic>)),
          ) ??
          const <String, ShoppingAmount>{},
      deleted: json['deleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$$WeekPlanImplToJson(_$WeekPlanImpl instance) =>
    <String, dynamic>{
      'weekKey': instance.weekKey,
      'days': instance.days.map((k, e) => MapEntry(k, e.toJson())),
      'quickAdds': instance.quickAdds.map((e) => e.toJson()).toList(),
      'excludedGeneralIds': instance.excludedGeneralIds.toList(),
      'checkedIds': instance.checkedIds.toList(),
      'unavailableIds': instance.unavailableIds.toList(),
      'amountOverrides': instance.amountOverrides.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'deleted': instance.deleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
