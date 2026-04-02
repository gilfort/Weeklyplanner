import '../models/week_plan.dart';
import 'json_file_repository.dart';

class WeekPlanRepository extends JsonFileRepository<WeekPlan> {
  WeekPlanRepository({required super.storage})
      : super(fileName: 'weekplans.json');

  @override
  WeekPlan fromJson(Map<String, dynamic> json) => WeekPlan.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeekPlan item) => item.toJson();

  Future<void> upsertWeekPlan(WeekPlan plan) =>
      upsert(plan, (p) => p.weekKey);

  Future<bool> deleteWeekPlan(String weekKey) =>
      deleteById(weekKey, (p) => p.weekKey);

  Future<WeekPlan?> findByWeekKey(String weekKey) async {
    final items = await readAll();
    try {
      return items.firstWhere((p) => p.weekKey == weekKey);
    } catch (_) {
      return null;
    }
  }
}
