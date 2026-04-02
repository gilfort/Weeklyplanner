import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/day_plan.dart';
import '../models/meal_slot.dart';
import '../models/week_plan.dart';
import '../repositories/week_plan_repository.dart';
import 'repository_providers.dart';

part 'week_plan_provider.g.dart';

@riverpod
class WeekPlanNotifier extends _$WeekPlanNotifier {
  late WeekPlanRepository _repo;
  late String _weekKey;

  @override
  Future<WeekPlan> build(String weekKey) async {
    _weekKey = weekKey;
    _repo = ref.watch(weekPlanRepositoryProvider);
    final found = await _repo.findByWeekKey(weekKey);
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

    await _repo.upsertWeekPlan(updatedPlan);
    state = AsyncData(updatedPlan);
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

    await _repo.upsertWeekPlan(updatedPlan);
    state = AsyncData(updatedPlan);
  }
}
