// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DayPlanImpl _$$DayPlanImplFromJson(Map<String, dynamic> json) =>
    _$DayPlanImpl(
      morning: json['morning'] == null
          ? null
          : MealSlot.fromJson(json['morning'] as Map<String, dynamic>),
      lunch: json['lunch'] == null
          ? null
          : MealSlot.fromJson(json['lunch'] as Map<String, dynamic>),
      dinner: json['dinner'] == null
          ? null
          : MealSlot.fromJson(json['dinner'] as Map<String, dynamic>),
      snack: json['snack'] == null
          ? null
          : MealSlot.fromJson(json['snack'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DayPlanImplToJson(_$DayPlanImpl instance) =>
    <String, dynamic>{
      'morning': instance.morning?.toJson(),
      'lunch': instance.lunch?.toJson(),
      'dinner': instance.dinner?.toJson(),
      'snack': instance.snack?.toJson(),
    };
