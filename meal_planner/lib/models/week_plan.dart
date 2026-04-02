import 'package:freezed_annotation/freezed_annotation.dart';
import 'day_plan.dart';

part 'week_plan.freezed.dart';
part 'week_plan.g.dart';

@freezed
abstract class WeekPlan with _$WeekPlan {
  const factory WeekPlan({
    /// Format: "2025-W14"
    required String weekKey,
    @Default({}) Map<String, DayPlan> days,
  }) = _WeekPlan;

  factory WeekPlan.fromJson(Map<String, dynamic> json) =>
      _$WeekPlanFromJson(json);
}
