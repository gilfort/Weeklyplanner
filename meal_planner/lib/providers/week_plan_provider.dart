import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/day_plan.dart';
import '../models/meal_slot.dart';
import '../models/shopping_item.dart';
import '../models/week_plan.dart';
import '../repositories/week_plan_repository.dart';
import 'repository_providers.dart';

part 'week_plan_provider.g.dart';

String shoppingKey(String name, String unit) =>
    '${name.toLowerCase()}|${unit.toLowerCase()}';

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
    final current = state.valueOrNull ?? WeekPlan(weekKey: _weekKey);
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
    final current = state.valueOrNull ?? WeekPlan(weekKey: _weekKey);
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

  // ── Shopping-list state (per-week) ──────────────────────────────────

  Future<void> _save(WeekPlan plan) async {
    final repo = await _repo;
    await repo.upsertWeekPlan(plan);
    state = AsyncData(plan);
  }

  WeekPlan get _current => state.valueOrNull ?? WeekPlan(weekKey: _weekKey);

  Future<void> addQuickAdd(ShoppingItem item) async {
    final current = _current;
    await _save(current.copyWith(
      quickAdds: [...current.quickAdds, item],
    ));
  }

  Future<void> removeQuickAdd(String id) async {
    final current = _current;
    await _save(current.copyWith(
      quickAdds: current.quickAdds.where((q) => q.id != id).toList(),
    ));
  }

  Future<void> updateQuickAdd(ShoppingItem item) async {
    final current = _current;
    await _save(current.copyWith(
      quickAdds: [
        for (final q in current.quickAdds)
          if (q.id == item.id) item else q,
      ],
    ));
  }

  Future<void> toggleExcludedGeneral(String generalId) async {
    final current = _current;
    final next = {...current.excludedGeneralIds};
    if (!next.remove(generalId)) next.add(generalId);
    await _save(current.copyWith(excludedGeneralIds: next));
  }

  Future<void> toggleChecked(String key) async {
    final current = _current;
    final next = {...current.checkedKeys};
    if (!next.remove(key)) next.add(key);
    await _save(current.copyWith(checkedKeys: next));
  }

  Future<void> toggleUnavailable(String key) async {
    final current = _current;
    final next = {...current.unavailableKeys};
    if (!next.remove(key)) next.add(key);
    await _save(current.copyWith(unavailableKeys: next));
  }

  Future<void> setAmountOverride(String key, double amount) async {
    final current = _current;
    await _save(current.copyWith(
      amountOverrides: {...current.amountOverrides, key: amount},
    ));
  }

  Future<void> clearAmountOverride(String key) async {
    final current = _current;
    final next = {...current.amountOverrides}..remove(key);
    await _save(current.copyWith(amountOverrides: next));
  }

  /// Resets ONLY the transient shopping-list markers (checked, unavailable,
  /// amount overrides). Keeps quickAdds and excludedGeneralIds so a fresh
  /// shop next day still respects the user's week-level choices.
  Future<void> finishShopping() async {
    final current = _current;
    await _save(current.copyWith(
      checkedKeys: const {},
      unavailableKeys: const {},
      amountOverrides: const {},
    ));
  }
}
