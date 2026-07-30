import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../providers/current_week_provider.dart';
import '../providers/derived_shopping_list_provider.dart';
import '../providers/general_items_provider.dart';
import '../providers/ingredient_catalog_provider.dart';
import '../providers/unit_provider.dart';
import '../providers/week_plan_provider.dart';
import '../theme.dart';

const _uuid = Uuid();

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Einkaufsliste'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Woche'),
              Tab(text: 'Generell'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _WeeklyShoppingTab(),
            _GeneralItemsTab(),
          ],
        ),
      ),
    );
  }
}

// ── Tab 1: Weekly shopping list (derived from week plan) ────────────

class _WeeklyShoppingTab extends ConsumerWidget {
  const _WeeklyShoppingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekKey = ref.watch(currentWeekKeyProvider);
    final derivedAsync = ref.watch(derivedShoppingListProvider);
    final weekPlanAsync = ref.watch(weekPlanNotifierProvider(weekKey));

    return derivedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorRetryWidget(
        message: 'Einkaufsliste konnte nicht geladen werden.',
        onRetry: () => ref.invalidate(derivedShoppingListProvider),
      ),
      data: (items) {
        final weekPlan = weekPlanAsync.valueOrNull;
        final checkedKeys = weekPlan?.checkedKeys ?? const <String>{};
        final unavailableKeys = weekPlan?.unavailableKeys ?? const <String>{};
        final quickAddIds = {
          for (final q in weekPlan?.quickAdds ?? const <ShoppingItem>[]) q.id,
        };

        if (items.isEmpty) {
          return Column(
            children: [
              const _QuickAddField(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 80,
                            color: Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text('Einkaufsliste ist leer',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text(
                          'Plane Rezepte im Wochenplan oder\nfüge generelle Artikel hinzu.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // Separate available and unavailable items
        final availableItems = <ShoppingItem>[];
        final unavailableItems = <ShoppingItem>[];
        for (final item in items) {
          final key = shoppingKey(item.name, item.unit);
          if (unavailableKeys.contains(key)) {
            unavailableItems.add(item);
          } else {
            availableItems.add(item);
          }
        }

        // Group available items by category
        final grouped = <String, List<ShoppingItem>>{};
        for (final item in availableItems) {
          final cat = item.category.isEmpty ? 'Sonstiges' : item.category;
          grouped.putIfAbsent(cat, () => []).add(item);
        }

        // Sort categories alphabetically, but "Sonstiges" last
        final sortedKeys = grouped.keys.toList()
          ..sort((a, b) {
            if (a == 'Sonstiges') return 1;
            if (b == 'Sonstiges') return -1;
            return a.compareTo(b);
          });

        return Column(
          children: [
            const _QuickAddField(),
            Expanded(
              child: RuledPaperBackground(
                showMargin: true,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    for (final category in sortedKeys) ...[
                      _CategoryHeader(category: category),
                      for (final item in grouped[category]!)
                        _ShoppingItemTile(
                          item: item,
                          isChecked: checkedKeys.contains(
                            shoppingKey(item.name, item.unit),
                          ),
                          isUnavailable: false,
                          isQuickAdd: quickAddIds.contains(item.id),
                        ),
                    ],
                    if (unavailableItems.isNotEmpty) ...[
                      _CategoryHeader(
                        category: 'Nicht verfügbar',
                        isUnavailable: true,
                      ),
                      for (final item in unavailableItems)
                        _ShoppingItemTile(
                          item: item,
                          isChecked: checkedKeys.contains(
                            shoppingKey(item.name, item.unit),
                          ),
                          isUnavailable: true,
                          isQuickAdd: quickAddIds.contains(item.id),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: () => _finishShopping(context, ref),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Einkauf abschließen'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _finishShopping(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Einkauf abschließen?'),
        content: const Text(
            'Alle Häkchen und „nicht verfügbar"-Markierungen\nwerden zurückgesetzt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Abschließen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final weekKey = ref.read(currentWeekKeyProvider);
      await ref
          .read(weekPlanNotifierProvider(weekKey).notifier)
          .finishShopping();
    }
  }
}

class _CategoryHeader extends StatelessWidget {
  final String category;
  final bool isUnavailable;
  const _CategoryHeader({
    required this.category,
    this.isUnavailable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        category,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isUnavailable
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ShoppingItemTile extends ConsumerWidget {
  final ShoppingItem item;
  final bool isChecked;
  final bool isUnavailable;
  final bool isQuickAdd;

  const _ShoppingItemTile({
    required this.item,
    required this.isChecked,
    this.isUnavailable = false,
    this.isQuickAdd = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountStr = item.amount == item.amount.roundToDouble()
        ? item.amount.toInt().toString()
        : item.amount.toStringAsFixed(1);

    final muted = isChecked || isUnavailable;
    final textColor = muted ? PaperTheme.checked : PaperTheme.ink;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Checkbox(
              value: isChecked,
              onChanged: (_) => _toggleChecked(ref),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => _editAmount(context, ref),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${item.name}  $amountStr ${item.unit}'.trim(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        decoration:
                            isChecked ? TextDecoration.lineThrough : null,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: isUnavailable ? 'Wieder verfügbar' : 'Nicht verfügbar',
            child: SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: isUnavailable,
                onChanged: (_) => _toggleUnavailable(ref),
                side: const BorderSide(
                  color: Color.fromARGB(153, 0xC0, 0x39, 0x2B),
                  width: 1.5,
                ),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return PaperTheme.error;
                  }
                  return Colors.transparent;
                }),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );

    if (!isQuickAdd) return tile;

    // Quick-add items are swipe-to-delete (week-scoped, ad-hoc).
    return Dismissible(
      key: ValueKey('quickadd-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        final weekKey = ref.read(currentWeekKeyProvider);
        ref
            .read(weekPlanNotifierProvider(weekKey).notifier)
            .removeQuickAdd(item.id);
      },
      child: tile,
    );
  }

  Future<void> _toggleChecked(WidgetRef ref) async {
    final weekKey = ref.read(currentWeekKeyProvider);
    await ref
        .read(weekPlanNotifierProvider(weekKey).notifier)
        .toggleChecked(shoppingKey(item.name, item.unit));
  }

  Future<void> _toggleUnavailable(WidgetRef ref) async {
    final weekKey = ref.read(currentWeekKeyProvider);
    await ref
        .read(weekPlanNotifierProvider(weekKey).notifier)
        .toggleUnavailable(shoppingKey(item.name, item.unit));
  }

  Future<void> _editAmount(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => _EditAmountDialog(item: item),
    );
    if (result == null) return;

    final weekKey = ref.read(currentWeekKeyProvider);
    final notifier = ref.read(weekPlanNotifierProvider(weekKey).notifier);
    final key = shoppingKey(item.name, item.unit);

    if (isQuickAdd) {
      // Edit stored quick-add directly (keeps identity).
      await notifier.updateQuickAdd(item.copyWith(amount: result));
    } else {
      await notifier.setAmountOverride(key, result);
    }
  }
}

// ── Dialog for editing the amount of a shopping-list item ────────────

class _EditAmountDialog extends StatefulWidget {
  final ShoppingItem item;
  const _EditAmountDialog({required this.item});

  @override
  State<_EditAmountDialog> createState() => _EditAmountDialogState();
}

class _EditAmountDialogState extends State<_EditAmountDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final a = widget.item.amount;
    _ctrl = TextEditingController(
      text: a == a.roundToDouble() ? a.toInt().toString() : a.toString(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.item.name} bearbeiten'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        ],
        decoration: InputDecoration(
          labelText: 'Menge',
          suffixText: widget.item.unit.isEmpty ? null : widget.item.unit,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () {
            final parsed =
                double.tryParse(_ctrl.text.replaceAll(',', '.'));
            if (parsed == null) return;
            Navigator.of(context).pop(parsed);
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

// ── Quick-add field for one-off shopping items ────────────────────────

class _QuickAddField extends ConsumerStatefulWidget {
  const _QuickAddField();

  @override
  ConsumerState<_QuickAddField> createState() => _QuickAddFieldState();
}

class _QuickAddFieldState extends ConsumerState<_QuickAddField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Schnell hinzufügen…',
                prefixIcon: const Icon(Icons.add_shopping_cart, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addItem(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: _addItem,
            icon: const Icon(Icons.add, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Future<void> _addItem() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final match = RegExp(r'^(\d+(?:[.,]\d+)?)\s*[xX]?\s+(.+)$').firstMatch(text);
    final double amount;
    final String name;
    if (match != null) {
      amount = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 1;
      name = match.group(2)!;
    } else {
      amount = 1;
      name = text;
    }

    final item = ShoppingItem(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      unit: '',
      category: '',
      isChecked: false,
      source: ShoppingSource.general,
    );

    final weekKey = ref.read(currentWeekKeyProvider);
    await ref
        .read(weekPlanNotifierProvider(weekKey).notifier)
        .addQuickAdd(item);
    _controller.clear();
    _focusNode.requestFocus();
  }
}

// ── Tab 2: General items (always-buy list) ──────────────────────────

class _GeneralItemsTab extends ConsumerWidget {
  const _GeneralItemsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generalAsync = ref.watch(generalItemsProvider);
    final weekKey = ref.watch(currentWeekKeyProvider);
    final weekPlanAsync = ref.watch(weekPlanNotifierProvider(weekKey));

    return generalAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorRetryWidget(
        message: 'Artikel konnten nicht geladen werden.',
        onRetry: () => ref.invalidate(generalItemsProvider),
      ),
      data: (items) {
        final excluded =
            weekPlanAsync.valueOrNull?.excludedGeneralIds ?? const <String>{};
        return Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 80,
                                color: Theme.of(context).colorScheme.outlineVariant),
                            const SizedBox(height: 16),
                            Text('Keine generellen Artikel',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            const Text(
                              'Tippe auf + um Artikel hinzuzufügen,\ndie du immer brauchst.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RuledPaperBackground(
                      showMargin: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _GeneralItemTile(
                            item: item,
                            isExcludedThisWeek: excluded.contains(item.id),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _GeneralItemTile extends ConsumerWidget {
  final GeneralItem item;
  final bool isExcludedThisWeek;
  const _GeneralItemTile({
    required this.item,
    required this.isExcludedThisWeek,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountStr = item.amount == item.amount.roundToDouble()
        ? item.amount.toInt().toString()
        : item.amount.toStringAsFixed(1);

    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: Container(
        // Swipe right → exclude/include for this week
        color: Colors.orange,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          isExcludedThisWeek ? Icons.visibility : Icons.visibility_off,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        // Swipe left → delete
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Toggle exclusion for current week, but keep tile in list.
          final weekKey = ref.read(currentWeekKeyProvider);
          await ref
              .read(weekPlanNotifierProvider(weekKey).notifier)
              .toggleExcludedGeneral(item.id);
          return false;
        }
        // endToStart → delete with confirmation
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Artikel löschen?'),
                content: Text(
                    '„${item.name}" wird dauerhaft aus der generellen Liste entfernt.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Abbrechen'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Löschen'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          ref.read(generalItemsProvider.notifier).delete(item.id);
        }
      },
      child: Container(
        color: isExcludedThisWeek
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : null,
        child: ListTile(
          title: Text(
            item.name,
            style: TextStyle(
              decoration: isExcludedThisWeek ? TextDecoration.lineThrough : null,
              color: isExcludedThisWeek
                  ? theme.colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
          subtitle: Text(
            isExcludedThisWeek
                ? '$amountStr ${item.unit}  ·  Diese Woche ausgeschlossen'
                    .trim()
                : '$amountStr ${item.unit}'.trim(),
          ),
          trailing: item.category.isNotEmpty
              ? Chip(
                  label: Text(item.category),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                )
              : null,
          onTap: () => _editItem(context, ref),
        ),
      ),
    );
  }

  Future<void> _editItem(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<GeneralItem>(
      context: context,
      builder: (_) => _GeneralItemDialog(existing: item),
    );
    if (result != null) {
      await ref.read(generalItemsProvider.notifier).upsert(result);
      await ref.read(ingredientCatalogProvider.notifier).learnIngredient(
            name: result.name,
            unit: result.unit,
            category: result.category,
          );
      if (result.unit.isNotEmpty) {
        await ref.read(unitsProvider.notifier).addUnit(result.unit);
      }
    }
  }
}

// ── FAB is placed in the main screen for adding general items ───────

class ShoppingListFab extends ConsumerWidget {
  const ShoppingListFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _addGeneralItem(context, ref),
      child: const Icon(Icons.add),
    );
  }

  Future<void> _addGeneralItem(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<GeneralItem>(
      context: context,
      builder: (_) => const _GeneralItemDialog(),
    );
    if (result != null) {
      await ref.read(generalItemsProvider.notifier).upsert(result);
      await ref.read(ingredientCatalogProvider.notifier).learnIngredient(
            name: result.name,
            unit: result.unit,
            category: result.category,
          );
      if (result.unit.isNotEmpty) {
        await ref.read(unitsProvider.notifier).addUnit(result.unit);
      }
    }
  }
}

// ── Dialog for creating/editing a general item ──────────────────────

class _GeneralItemDialog extends ConsumerStatefulWidget {
  final GeneralItem? existing;
  const _GeneralItemDialog({this.existing});

  @override
  ConsumerState<_GeneralItemDialog> createState() =>
      _GeneralItemDialogState();
}

class _GeneralItemDialogState extends ConsumerState<_GeneralItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _categoryCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl =
        TextEditingController(text: e != null ? e.amount.toString() : '1');
    _unitCtrl = TextEditingController(text: e?.unit ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _unitCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final catalog = ref.watch(ingredientCatalogProvider).valueOrNull ?? [];
    final units = ref.watch(unitsProvider).valueOrNull ?? [];

    return AlertDialog(
      title: Text(isEdit ? 'Artikel bearbeiten' : 'Neuer Artikel'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RawAutocomplete<IngredientCatalogEntry>(
                  textEditingController: _nameCtrl,
                  focusNode: FocusNode(),
                  optionsBuilder: (textEditingValue) {
                    final q = textEditingValue.text.trim().toLowerCase();
                    if (q.isEmpty) return const Iterable.empty();
                    return catalog
                        .where((e) => e.name.toLowerCase().contains(q));
                  },
                  displayStringForOption: (e) => e.name,
                  onSelected: (entry) {
                    if (entry.defaultUnit.isNotEmpty) {
                      _unitCtrl.text = entry.defaultUnit;
                    }
                    if (entry.defaultCategory.isNotEmpty) {
                      _categoryCtrl.text = entry.defaultCategory;
                    }
                    setState(() {});
                  },
                  fieldViewBuilder:
                      (context, textCtrl, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: textCtrl,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Name *'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Erforderlich'
                              : null,
                      onFieldSubmitted: (_) => onFieldSubmitted(),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxHeight: 150, maxWidth: 280),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final entry = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text(entry.name),
                                subtitle: entry.defaultUnit.isNotEmpty
                                    ? Text(entry.defaultUnit)
                                    : null,
                                onTap: () => onSelected(entry),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Menge'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.,]')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Autocomplete<String>(
                        initialValue: _unitCtrl.value,
                        optionsBuilder: (textEditingValue) {
                          final q =
                              textEditingValue.text.trim().toLowerCase();
                          if (q.isEmpty) return units;
                          return units
                              .where((u) => u.toLowerCase().contains(q));
                        },
                        onSelected: (value) => _unitCtrl.text = value,
                        fieldViewBuilder: (context, textCtrl, focusNode,
                            onFieldSubmitted) {
                          textCtrl.addListener(() {
                            if (_unitCtrl.text != textCtrl.text) {
                              _unitCtrl.text = textCtrl.text;
                            }
                          });
                          return TextFormField(
                            controller: textCtrl,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                                labelText: 'Einheit'),
                            onFieldSubmitted: (_) => onFieldSubmitted(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildCategoryAutocomplete(catalog),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Speichern'),
        ),
      ],
    );
  }

  Widget _buildCategoryAutocomplete(List<IngredientCatalogEntry> catalog) {
    final categories = <String>{
      for (final e in catalog)
        if (e.defaultCategory.isNotEmpty) e.defaultCategory,
    }.toList()
      ..sort();

    return Autocomplete<String>(
      initialValue: _categoryCtrl.value,
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text.trim().toLowerCase();
        if (q.isEmpty) return categories;
        return categories.where((c) => c.toLowerCase().contains(q));
      },
      onSelected: (value) => _categoryCtrl.text = value,
      fieldViewBuilder: (context, textCtrl, focusNode, onFieldSubmitted) {
        textCtrl.addListener(() {
          if (_categoryCtrl.text != textCtrl.text) {
            _categoryCtrl.text = textCtrl.text;
          }
        });
        return TextFormField(
          controller: textCtrl,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Kategorie (optional)',
          ),
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final item = GeneralItem(
      id: widget.existing?.id ?? _uuid.v4(),
      name: _nameCtrl.text.trim(),
      amount: double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 1,
      unit: _unitCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
    );

    Navigator.of(context).pop(item);
  }
}

class _ErrorRetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetryWidget({required this.message, required this.onRetry});

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
