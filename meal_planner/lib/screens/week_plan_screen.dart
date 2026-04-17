import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/models.dart';
import '../providers/current_week_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/week_plan_provider.dart';
import '../theme.dart';
import '../widgets/recipe_picker_sheet.dart';
import '../widgets/sync_status_icon.dart';

/// The 7 day keys used in WeekPlan.days
const _dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
const _dayLabels = {
  'mon': 'Montag',
  'tue': 'Dienstag',
  'wed': 'Mittwoch',
  'thu': 'Donnerstag',
  'fri': 'Freitag',
  'sat': 'Samstag',
  'sun': 'Sonntag',
};
const _mealKeys = ['morning', 'lunch', 'dinner', 'snack'];
const _mealLabels = {
  'morning': 'Morgen',
  'lunch': 'Mittag',
  'dinner': 'Abend',
  'snack': 'Snack',
};
const _mealIcons = {
  'morning': Icons.wb_sunny_outlined,
  'lunch': Icons.restaurant_outlined,
  'dinner': Icons.nightlight_outlined,
  'snack': Icons.cookie_outlined,
};

class WeekPlanScreen extends ConsumerWidget {
  const WeekPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekKey = ref.watch(currentWeekKeyProvider);
    final weekPlanAsync = ref.watch(weekPlanNotifierProvider(weekKey));

    return Scaffold(
      appBar: AppBar(
        title: _WeekNavigationBar(weekKey: weekKey),
        centerTitle: true,
        actions: [
          const SyncStatusIcon(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: weekPlanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorRetry(
          message: 'Wochenplan konnte nicht geladen werden.',
          onRetry: () => ref.invalidate(weekPlanNotifierProvider(weekKey)),
        ),
        data: (weekPlan) => RuledPaperBackground(
          child: _WeekList(weekPlan: weekPlan, weekKey: weekKey),
        ),
      ),
    );
  }
}

/// Navigation bar with left/right arrows and the current week key as title.
class _WeekNavigationBar extends ConsumerWidget {
  final String weekKey;
  const _WeekNavigationBar({required this.weekKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeWeek(ref, -1),
        ),
        Text(weekKey, style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _changeWeek(ref, 1),
        ),
      ],
    );
  }

  void _changeWeek(WidgetRef ref, int delta) {
    final current = ref.read(currentWeekKeyProvider);
    final parts = current.split('-W');
    var year = int.parse(parts[0]);
    var week = int.parse(parts[1]) + delta;

    if (week < 1) {
      year--;
      week = 52;
    } else if (week > 52) {
      year++;
      week = 1;
    }

    ref
        .read(currentWeekKeyProvider.notifier)
        .set('$year-W${week.toString().padLeft(2, '0')}');
  }
}

/// The collapsible day list view.
class _WeekList extends ConsumerStatefulWidget {
  final WeekPlan weekPlan;
  final String weekKey;

  const _WeekList({required this.weekPlan, required this.weekKey});

  @override
  ConsumerState<_WeekList> createState() => _WeekListState();
}

class _WeekListState extends ConsumerState<_WeekList> {
  // Track which days are expanded — default: all expanded
  late final Set<String> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = {..._dayKeys};
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);
    final recipes = recipesAsync.valueOrNull ?? [];
    final recipeMap = {for (final r in recipes) r.id: r};

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        for (final dayKey in _dayKeys)
          _buildDaySection(context, dayKey, recipeMap),
      ],
    );
  }

  Widget _buildDaySection(
    BuildContext context,
    String dayKey,
    Map<String, Recipe> recipeMap,
  ) {
    final isExpanded = _expanded.contains(dayKey);
    final dayPlan = widget.weekPlan.days[dayKey];
    final dayLabel = _dayLabels[dayKey] ?? dayKey;

    // Count filled slots for collapsed summary
    final filledCount = _mealKeys.where((m) {
      final slot = _getSlot(dayPlan, m);
      return slot != null && slot.recipeId != null;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header — tappable to expand/collapse
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expanded.remove(dayKey);
              } else {
                _expanded.add(dayKey);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: PaperTheme.ink,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dayLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: PaperTheme.ruled,
                        ),
                  ),
                ),
                if (!isExpanded && filledCount > 0)
                  Text(
                    '$filledCount Gerichte',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PaperTheme.checked,
                        ),
                  ),
              ],
            ),
          ),
        ),
        // Meal slots
        if (isExpanded)
          for (final mealKey in _mealKeys)
            _MealSlotRow(
              dayKey: dayKey,
              mealKey: mealKey,
              slot: _getSlot(dayPlan, mealKey),
              recipeMap: recipeMap,
              weekKey: widget.weekKey,
            ),
        if (isExpanded)
          Divider(
            color: PaperTheme.ruled,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  MealSlot? _getSlot(DayPlan? dayPlan, String mealKey) {
    return switch (mealKey) {
      'morning' => dayPlan?.morning,
      'lunch' => dayPlan?.lunch,
      'dinner' => dayPlan?.dinner,
      'snack' => dayPlan?.snack,
      _ => null,
    };
  }
}

/// A single meal slot row: "- Morgen: Rezeptname [checkbox]"
class _MealSlotRow extends ConsumerWidget {
  final String dayKey;
  final String mealKey;
  final MealSlot? slot;
  final Map<String, Recipe> recipeMap;
  final String weekKey;

  const _MealSlotRow({
    required this.dayKey,
    required this.mealKey,
    required this.slot,
    required this.recipeMap,
    required this.weekKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealLabel = _mealLabels[mealKey] ?? mealKey;
    final mealIcon = _mealIcons[mealKey] ?? Icons.restaurant;
    final recipe =
        slot?.recipeId != null ? recipeMap[slot!.recipeId] : null;
    final isEmpty = slot == null || slot!.recipeId == null;
    final isDeleted = !isEmpty && recipe == null;
    final isDone = slot?.done ?? false;

    return InkWell(
      onTap: isEmpty
          ? () => _pickRecipe(context, ref)
          : () => _editSlot(context, ref, recipe),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 4, 12, 4),
        child: Row(
          children: [
            // Meal icon (replaces text label to avoid wrapping on small screens)
            Tooltip(
              message: mealLabel,
              child: Icon(mealIcon, size: 22, color: PaperTheme.checked),
            ),
            const SizedBox(width: 12),
            // Recipe name or empty hint
            Expanded(
              child: isEmpty
                  ? Text(
                      '+ hinzufügen',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PaperTheme.checked,
                            fontStyle: FontStyle.italic,
                          ),
                    )
                  : isDeleted
                      ? Text(
                          'Rezept gelöscht',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: PaperTheme.error,
                                    fontStyle: FontStyle.italic,
                                  ),
                        )
                      : Text(
                          '${recipe!.name} (${slot!.servings ?? recipe.servings}P)',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color:
                                        isDone ? PaperTheme.checked : null,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
            ),
            // Done checkbox (only for filled slots)
            if (!isEmpty && !isDeleted)
              SizedBox(
                width: 32,
                height: 32,
                child: Checkbox(
                  value: isDone,
                  onChanged: (_) => ref
                      .read(weekPlanNotifierProvider(weekKey).notifier)
                      .toggleMealDone(dayKey, mealKey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickRecipe(BuildContext context, WidgetRef ref) async {
    final recipe = await showModalBottomSheet<Recipe>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const RecipePickerSheet(),
    );

    if (recipe != null) {
      await ref
          .read(weekPlanNotifierProvider(weekKey).notifier)
          .setMealSlot(
            dayKey,
            mealKey,
            MealSlot(recipeId: recipe.id, servings: recipe.servings),
          );
    }
  }

  Future<void> _editSlot(
    BuildContext context,
    WidgetRef ref,
    Recipe? recipe,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => _SlotEditor(
        recipe: recipe,
        slot: slot!,
        onServingsChanged: (servings) async {
          await ref
              .read(weekPlanNotifierProvider(weekKey).notifier)
              .setMealSlot(
                dayKey,
                mealKey,
                MealSlot(recipeId: slot!.recipeId, servings: servings),
              );
        },
        onDelete: () async {
          await ref
              .read(weekPlanNotifierProvider(weekKey).notifier)
              .setMealSlot(dayKey, mealKey, null);
        },
      ),
    );
  }
}

/// Bottom sheet for editing a filled slot (servings stepper + delete).
class _SlotEditor extends StatefulWidget {
  final Recipe? recipe;
  final MealSlot slot;
  final Future<void> Function(int servings) onServingsChanged;
  final Future<void> Function() onDelete;

  const _SlotEditor({
    required this.recipe,
    required this.slot,
    required this.onServingsChanged,
    required this.onDelete,
  });

  @override
  State<_SlotEditor> createState() => _SlotEditorState();
}

class _SlotEditorState extends State<_SlotEditor> {
  late int _servings;

  @override
  void initState() {
    super.initState();
    _servings = widget.slot.servings ?? widget.recipe?.servings ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.recipe?.name ?? 'Unbekanntes Rezept',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Servings stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _servings > 1
                    ? () async {
                        setState(() => _servings--);
                        await widget.onServingsChanged(_servings);
                      }
                    : null,
              ),
              Text(
                '$_servings Portionen',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () async {
                  setState(() => _servings++);
                  await widget.onServingsChanged(_servings);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Delete button
          OutlinedButton.icon(
            onPressed: () async {
              await widget.onDelete();
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label:
                const Text('Entfernen', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48,
              color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }
}
