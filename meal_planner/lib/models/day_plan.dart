import 'package:freezed_annotation/freezed_annotation.dart';
import 'meal_slot.dart';

part 'day_plan.freezed.dart';
part 'day_plan.g.dart';

@freezed
abstract class DayPlan with _$DayPlan {
  const factory DayPlan({
    MealSlot? morning,
    MealSlot? lunch,
    MealSlot? dinner,
    MealSlot? snack,
  }) = _DayPlan;

  factory DayPlan.fromJson(Map<String, dynamic> json) =>
      _$DayPlanFromJson(json);
}
