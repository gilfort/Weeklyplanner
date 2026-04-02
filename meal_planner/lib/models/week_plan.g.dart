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
    );

Map<String, dynamic> _$$WeekPlanImplToJson(_$WeekPlanImpl instance) =>
    <String, dynamic>{
      'weekKey': instance.weekKey,
      'days': instance.days.map((k, e) => MapEntry(k, e.toJson())),
    };
