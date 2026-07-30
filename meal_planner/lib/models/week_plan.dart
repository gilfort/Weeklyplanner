import 'package:freezed_annotation/freezed_annotation.dart';
import 'day_plan.dart';
import 'shopping_item.dart';

part 'week_plan.freezed.dart';
part 'week_plan.g.dart';

@freezed
abstract class WeekPlan with _$WeekPlan {
  const factory WeekPlan({
    /// Format: "2025-W14"
    required String weekKey,
    @Default({}) Map<String, DayPlan> days,

    /// Ad-hoc shopping items added via quick-add. Scoped to this week only.
    @Default(<ShoppingItem>[]) List<ShoppingItem> quickAdds,

    /// IDs of GeneralItems hidden from this week's shopping list.
    /// Does not affect the underlying general items or recipe ingredients.
    @Default(<String>{}) Set<String> excludedGeneralIds,

    /// Shopping-list items marked as bought (keyed by "name|unit", lowercase).
    @Default(<String>{}) Set<String> checkedKeys,

    /// Shopping-list items marked as not available (keyed by "name|unit").
    @Default(<String>{}) Set<String> unavailableKeys,

    /// Per-week amount override for shopping items (keyed by "name|unit").
    /// Replaces the derived amount; never mutates the recipe or general item.
    @Default(<String, double>{}) Map<String, double> amountOverrides,
  }) = _WeekPlan;

  factory WeekPlan.fromJson(Map<String, dynamic> json) =>
      _$WeekPlanFromJson(json);
}
