import '../models/week_plan.dart';
import 'entity_repository.dart';

class WeekPlanRepository extends EntityRepository<WeekPlan> {
  WeekPlanRepository({required super.storage}) : super(dirName: 'weeks');

  @override
  WeekPlan fromJson(Map<String, dynamic> json) => WeekPlan.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeekPlan item) => item.toJson();

  @override
  String idOf(WeekPlan item) => item.weekKey;

  @override
  bool isDeleted(WeekPlan item) => item.deleted;

  @override
  DateTime? deletedAtOf(WeekPlan item) => item.deletedAt;

  @override
  WeekPlan markDeleted(WeekPlan item, DateTime at) =>
      item.copyWith(deleted: true, deletedAt: at);

  Future<void> upsertWeekPlan(WeekPlan plan) => upsert(plan);

  Future<bool> deleteWeekPlan(String weekKey) => delete(weekKey);

  Future<WeekPlan?> findByWeekKey(String weekKey) => findById(weekKey);
}
