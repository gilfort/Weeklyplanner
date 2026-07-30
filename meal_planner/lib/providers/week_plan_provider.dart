import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/day_plan.dart';
import '../models/meal_slot.dart';
import '../models/quick_add_item.dart';
import '../models/shopping_amount.dart';
import '../models/week_plan.dart';
import '../repositories/week_plan_repository.dart';
import 'repository_providers.dart';

part 'week_plan_provider.g.dart';

@riverpod
class WeekPlanNotifier extends _$WeekPlanNotifier {
  late String _weekKey;

  Future<WeekPlanRepository> get _repo =>
      ref.read(weekPlanRepositoryProvider.future);

  @override
  Future<WeekPlan> build(String weekKey) async {
    _weekKey = weekKey;
    final repo = await ref.watch(weekPlanRepositoryProvider.future);
    final found = await repo.findByWeekKey(weekKey);
    return found ?? WeekPlan(weekKey: weekKey);
  }

  Future<void> setMealSlot(
    String day,
    String meal,
    MealSlot? slot,
  ) async {
    final current = _current;
    final currentDay = current.days[day] ?? const DayPlan();

    final updatedDay = switch (meal) {
      'morning' => currentDay.copyWith(morning: slot),
      'lunch' => currentDay.copyWith(lunch: slot),
      'dinner' => currentDay.copyWith(dinner: slot),
      'snack' => currentDay.copyWith(snack: slot),
      _ => currentDay,
    };

    final updatedPlan = current.copyWith(
      days: {...current.days, day: updatedDay},
    );

    await _save(updatedPlan);
  }

  Future<void> toggleMealDone(String day, String meal) async {
    final current = _current;
    final currentDay = current.days[day] ?? const DayPlan();

    final slot = switch (meal) {
      'morning' => currentDay.morning,
      'lunch' => currentDay.lunch,
      'dinner' => currentDay.dinner,
      'snack' => currentDay.snack,
      _ => null,
    };

    if (slot == null || slot.recipeId == null) return;

    final toggled = slot.copyWith(done: !slot.done);

    final updatedDay = switch (meal) {
      'morning' => currentDay.copyWith(morning: toggled),
      'lunch' => currentDay.copyWith(lunch: toggled),
      'dinner' => currentDay.copyWith(dinner: toggled),
      'snack' => currentDay.copyWith(snack: toggled),
      _ => currentDay,
    };

    final updatedPlan = current.copyWith(
      days: {...current.days, day: updatedDay},
    );

    await _save(updatedPlan);
  }

  // ── Shopping-list state (per-week, keyed by catalog id) ─────────────

  Future<void> _save(WeekPlan plan) async {
    final repo = await _repo;
    await repo.upsertWeekPlan(plan);
    state = AsyncData(plan);
  }

  WeekPlan get _current => state.valueOrNull ?? WeekPlan(weekKey: _weekKey);

  /// Adds an ad-hoc item. A second quick-add of the same ingredient in the
  /// same unit tops up the existing one instead of creating a duplicate line.
  Future<void> addQuickAdd(QuickAddItem item) async {
    final current = _current;
    final index = current.quickAdds.indexWhere(
      (q) => q.catalogId == item.catalogId && q.unit == item.unit,
    );
    final next = [...current.quickAdds];
    if (index >= 0) {
      next[index] =
          next[index].copyWith(amount: next[index].amount + item.amount);
    } else {
      next.add(item);
    }
    await _save(current.copyWith(quickAdds: next));
  }

  /// Removes every quick-add contribution for [catalogId].
  Future<void> removeQuickAdd(String catalogId) async {
    final current = _current;
    await _save(current.copyWith(
      quickAdds:
          current.quickAdds.where((q) => q.catalogId != catalogId).toList(),
    ));
  }

  Future<void> toggleExcludedGeneral(String catalogId) async {
    final current = _current;
    final next = {...current.excludedGeneralIds};
    if (!next.remove(catalogId)) next.add(catalogId);
    await _save(current.copyWith(excludedGeneralIds: next));
  }

  Future<void> toggleChecked(String catalogId) async {
    final current = _current;
    final next = {...current.checkedIds};
    if (!next.remove(catalogId)) next.add(catalogId);
    await _save(current.copyWith(checkedIds: next));
  }

  Future<void> toggleUnavailable(String catalogId) async {
    final current = _current;
    final next = {...current.unavailableIds};
    if (!next.remove(catalogId)) next.add(catalogId);
    await _save(current.copyWith(unavailableIds: next));
  }

  Future<void> setAmountOverride(String catalogId, ShoppingAmount amount) async {
    final current = _current;
    await _save(current.copyWith(
      amountOverrides: {...current.amountOverrides, catalogId: amount},
    ));
  }

  Future<void> clearAmountOverride(String catalogId) async {
    final current = _current;
    final next = {...current.amountOverrides}..remove(catalogId);
    await _save(current.copyWith(amountOverrides: next));
  }

  /// Resets ONLY the transient shopping-list markers (checked, unavailable,
  /// amount overrides). Keeps quickAdds and excludedGeneralIds so a fresh
  /// shop next day still respects the user's week-level choices.
  Future<void> finishShopping() async {
    final current = _current;
    await _save(current.copyWith(
      checkedIds: const {},
      unavailableIds: const {},
      amountOverrides: const {},
    ));
  }
}
