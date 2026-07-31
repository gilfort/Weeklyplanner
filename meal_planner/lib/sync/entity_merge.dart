import '../models/day_plan.dart';
import '../models/general_item.dart';
import '../models/ingredient_catalog_entry.dart';
import '../models/quick_add_item.dart';
import '../models/recipe.dart';
import '../models/shopping_amount.dart';
import '../models/week_plan.dart';
import 'three_way_merge.dart';

/// Three-way merges for the four synced entity types.
///
/// Each takes the base snapshot both devices last agreed on plus the two
/// current versions, and returns the reconciled entity. [preferRemote] only
/// matters for fields both sides changed to different values; it is the
/// caller's answer to "which file is newer".
///
/// All of these are pure — no I/O, no clock, no transport.

Recipe mergeRecipe(
  Recipe base,
  Recipe local,
  Recipe remote, {
  required bool preferRemote,
}) {
  final deletion = mergeDeletion(
    localDeleted: local.deleted,
    localDeletedAt: local.deletedAt,
    remoteDeleted: remote.deleted,
    remoteDeletedAt: remote.deletedAt,
  );
  return Recipe(
    id: local.id,
    name: mergeValue(base.name, local.name, remote.name,
        preferRemote: preferRemote),
    description: mergeValue(
        base.description, local.description, remote.description,
        preferRemote: preferRemote),
    servings: mergeValue(base.servings, local.servings, remote.servings,
        preferRemote: preferRemote),
    // Ingredients and tags merge as whole lists on purpose. Editing a recipe
    // is one deliberate act — a per-ingredient merge would happily keep a
    // line the other device just removed.
    ingredients: mergeValue(
        base.ingredients, local.ingredients, remote.ingredients,
        preferRemote: preferRemote, equals: listEquals),
    tags: mergeValue(base.tags, local.tags, remote.tags,
        preferRemote: preferRemote, equals: listEquals),
    deleted: deletion.deleted,
    deletedAt: deletion.deletedAt,
  );
}

GeneralItem mergeGeneralItem(
  GeneralItem base,
  GeneralItem local,
  GeneralItem remote, {
  required bool preferRemote,
}) {
  final deletion = mergeDeletion(
    localDeleted: local.deleted,
    localDeletedAt: local.deletedAt,
    remoteDeleted: remote.deleted,
    remoteDeletedAt: remote.deletedAt,
  );
  return GeneralItem(
    catalogId: local.catalogId,
    amount: mergeValue(base.amount, local.amount, remote.amount,
        preferRemote: preferRemote),
    unit: mergeValue(base.unit, local.unit, remote.unit,
        preferRemote: preferRemote),
    deleted: deletion.deleted,
    deletedAt: deletion.deletedAt,
  );
}

IngredientCatalogEntry mergeCatalogEntry(
  IngredientCatalogEntry base,
  IngredientCatalogEntry local,
  IngredientCatalogEntry remote, {
  required bool preferRemote,
}) {
  final deletion = mergeDeletion(
    localDeleted: local.deleted,
    localDeletedAt: local.deletedAt,
    remoteDeleted: remote.deleted,
    remoteDeletedAt: remote.deletedAt,
  );
  return IngredientCatalogEntry(
    id: local.id,
    name: mergeValue(base.name, local.name, remote.name,
        preferRemote: preferRemote),
    defaultUnit: mergeValue(
        base.defaultUnit, local.defaultUnit, remote.defaultUnit,
        preferRemote: preferRemote),
    defaultCategory: mergeValue(
        base.defaultCategory, local.defaultCategory, remote.defaultCategory,
        preferRemote: preferRemote),
    deleted: deletion.deleted,
    deletedAt: deletion.deletedAt,
  );
}

/// The week plan is the file two people actually touch at the same time:
/// one edits the plan at home while the other ticks items off in the shop.
/// Every part of it therefore merges independently — meal slots per slot,
/// shopping state per id — so neither side's work is overwritten.
WeekPlan mergeWeekPlan(
  WeekPlan base,
  WeekPlan local,
  WeekPlan remote, {
  required bool preferRemote,
}) {
  final deletion = mergeDeletion(
    localDeleted: local.deleted,
    localDeletedAt: local.deletedAt,
    remoteDeleted: remote.deleted,
    remoteDeletedAt: remote.deletedAt,
  );
  return WeekPlan(
    weekKey: local.weekKey,
    days: mergeMap<String, DayPlan>(
      base.days,
      local.days,
      remote.days,
      preferRemote: preferRemote,
      mergeEntry: (b, l, r, prefer) =>
          mergeDayPlan(b, l, r, preferRemote: prefer),
    ),
    quickAdds: mergeListByKey<String, QuickAddItem>(
      base.quickAdds,
      local.quickAdds,
      remote.quickAdds,
      keyOf: _quickAddKey,
      preferRemote: preferRemote,
    ),
    excludedGeneralIds: mergeSet(
      base.excludedGeneralIds,
      local.excludedGeneralIds,
      remote.excludedGeneralIds,
    ),
    checkedIds: mergeSet(base.checkedIds, local.checkedIds, remote.checkedIds),
    unavailableIds: mergeSet(
      base.unavailableIds,
      local.unavailableIds,
      remote.unavailableIds,
    ),
    amountOverrides: mergeMap<String, ShoppingAmount>(
      base.amountOverrides,
      local.amountOverrides,
      remote.amountOverrides,
      preferRemote: preferRemote,
    ),
    deleted: deletion.deleted,
    deletedAt: deletion.deletedAt,
  );
}

/// Merges a day slot by slot, so assigning Tuesday lunch on one device and
/// Thursday dinner on the other keeps both.
DayPlan mergeDayPlan(
  DayPlan base,
  DayPlan local,
  DayPlan remote, {
  required bool preferRemote,
}) =>
    DayPlan(
      morning: mergeValue(base.morning, local.morning, remote.morning,
          preferRemote: preferRemote),
      lunch: mergeValue(base.lunch, local.lunch, remote.lunch,
          preferRemote: preferRemote),
      dinner: mergeValue(base.dinner, local.dinner, remote.dinner,
          preferRemote: preferRemote),
      snack: mergeValue(base.snack, local.snack, remote.snack,
          preferRemote: preferRemote),
    );

/// Quick-adds are identified by ingredient *and* unit, matching how
/// [WeekPlanNotifier.addQuickAdd] tops up an existing entry.
String _quickAddKey(QuickAddItem item) => '${item.catalogId}|${item.unit}';
