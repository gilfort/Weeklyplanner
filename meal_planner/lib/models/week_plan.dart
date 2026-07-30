import 'package:freezed_annotation/freezed_annotation.dart';
import 'day_plan.dart';
import 'quick_add_item.dart';
import 'shopping_amount.dart';

part 'week_plan.freezed.dart';
part 'week_plan.g.dart';

@freezed
abstract class WeekPlan with _$WeekPlan {
  const factory WeekPlan({
    /// Format: "2025-W14"
    required String weekKey,
    @Default({}) Map<String, DayPlan> days,

    /// Ad-hoc shopping items added via quick-add. Scoped to this week only.
    @Default(<QuickAddItem>[]) List<QuickAddItem> quickAdds,

    /// Catalog ids of general items hidden from this week's shopping list.
    /// Does not affect the underlying general items or recipe ingredients.
    @Default(<String>{}) Set<String> excludedGeneralIds,

    /// Catalog ids of shopping lines marked as bought.
    @Default(<String>{}) Set<String> checkedIds,

    /// Catalog ids of shopping lines marked as not available.
    @Default(<String>{}) Set<String> unavailableIds,

    /// Per-week amount override for a shopping line, keyed by catalog id.
    /// Replaces the derived amounts entirely (one amount in one unit);
    /// never mutates the recipe, general item or catalog entry.
    @Default(<String, ShoppingAmount>{})
    Map<String, ShoppingAmount> amountOverrides,
    @Default(false) bool deleted,
    DateTime? deletedAt,
  }) = _WeekPlan;

  factory WeekPlan.fromJson(Map<String, dynamic> json) =>
      _$WeekPlanFromJson(json);
}
