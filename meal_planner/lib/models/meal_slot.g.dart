// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealSlotImpl _$$MealSlotImplFromJson(Map<String, dynamic> json) =>
    _$MealSlotImpl(
      recipeId: json['recipeId'] as String?,
      servings: (json['servings'] as num?)?.toInt(),
      done: json['done'] as bool? ?? false,
    );

Map<String, dynamic> _$$MealSlotImplToJson(_$MealSlotImpl instance) =>
    <String, dynamic>{
      'recipeId': instance.recipeId,
      'servings': instance.servings,
      'done': instance.done,
    };
