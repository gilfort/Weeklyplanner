import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../providers/derived_shopping_list_provider.dart';
import '../providers/general_items_provider.dart';
import '../providers/ingredient_catalog_provider.dart';
import '../providers/shopping_items_provider.dart';
import '../providers/unit_provider.dart';
import '../theme.dart';
import '../widgets/sync_status_icon.dart';

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
            const SyncStatusIcon(),
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
    final derivedAsync = ref.watch(derivedShoppingListProvider);
    final checkedAsync = ref.watch(shoppingItemsProvider);

    return derivedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorRetryWidget(
        message: 'Einkaufsliste konnte nicht geladen werden.',
        onRetry: () => ref.invalidate(derivedShoppingListProvider),
      ),
      data: (derivedItems) {
        // Merge quick-add (ad-hoc) items from persisted state
        final checkedItems = checkedAsync.valueOrNull ?? [];

        // Ad-hoc items: persisted items that are NOT just state markers
        // (they were added via quick-add and aren't checked/unavailable-only)
        final derivedKeys = <String>{
          for (final d in derivedItems)
            '${d.name.toLowerCase()}|${d.unit.toLowerCase()}',
        };
        final adHocItems = checkedItems.where((c) {
          final key = '${c.name.toLowerCase()}|${c.unit.toLowerCase()}';
          return !derivedKeys.contains(key) && !c.isChecked;
        }).toList();

        final items = [...derivedItems, ...adHocItems];

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

        // Build a set of checked item keys (name|unit) from persisted state
        final checkedKeys = <String>{
          for (final c in checkedItems)
            if (c.isChecked) '${c.name.toLowerCase()}|${c.unit.toLowerCase()}',
        };

        // Build unavailable keys set
        final unavailableKeys = <String>{
          for (final c in checkedItems)
            if (c.isUnavailable)
              '${c.name.toLowerCase()}|${c.unit.toLowerCase()}',
        };

        // Separate available and unavailable items
        final availableItems = <ShoppingItem>[];
        final unavailableItems = <ShoppingItem>[];
        for (final item in items) {
          final key =
              '${item.name.toLowerCase()}|${item.unit.toLowerCase()}';
          if (unavailableKeys.contains(key)) {
            unavailableItems.add(item);
          } else {
            availableItems.add(item);
          }
        }

        // Group available items by category
        final grouped = <String, List<ShoppingItem>>{};
        for (final item in availableItems) {
          final cat =
              item.category.isEmpty ? 'Sonstiges' : item.category;
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
            // Quick-add field for one-off items
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
                            '${item.name.toLowerCase()}|${item.unit.toLowerCase()}',
                          ),
                          isUnavailable: false,
                          onEdit: () => _editShoppingItem(context, ref, item),
                        ),
                    ],
                    // Unavailable section at bottom
                    if (unavailableItems.isNotEmpty) ...[
                      _CategoryHeader(
                        category: 'Nicht verfügbar',
                        isUnavailable: true,
                      ),
                      for (final item in unavailableItems)
                        _ShoppingItemTile(
                          item: item,
                          isChecked: checkedKeys.contains(
                            '${item.name.toLowerCase()}|${item.unit.toLowerCase()}',
                          ),
                          isUnavailable: true,
                          onEdit: () => _editShoppingItem(context, ref, item),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            // Reset button
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

  Future<void> _editShoppingItem(
    BuildContext context,
    WidgetRef ref,
    ShoppingItem item,
  ) async {
    final result = await showDialog<ShoppingItem>(
      context: context,
      builder: (_) => _ShoppingItemEditDialog(item: item),
    );
    if (result != null) {
      await ref.read(shoppingItemsProvider.notifier).upsert(result);
    }
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
      await ref.read(shoppingItemsProvider.notifier).clearAll();
      await ref.read(generalItemsProvider.notifier).resetExclusions();
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
  final VoidCallback? onEdit;

  const _ShoppingItemTile({
    required this.item,
    required this.isChecked,
    this.isUnavailable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountStr = item.amount == item.amount.roundToDouble()
        ? item.amount.toInt().toString()
        : item.amount.toStringAsFixed(1);

    final muted = isChecked || isUnavailable;
    final textColor = muted ? PaperTheme.checked : PaperTheme.ink;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          // Checked checkbox
          SizedBox(
            width: 32,
            height: 32,
            child: Checkbox(
              value: isChecked,
              onChanged: (_) => _toggle(ref),
            ),
          ),
          const SizedBox(width: 8),
          // Name + amount inline
          Expanded(
            child: Text(
              '${item.name}  $amountStr ${item.unit}'.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          // Unavailable checkbox
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
          // Edit button (Change #6)
          if (onEdit != null)
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                tooltip: 'Bearbeiten',
              ),
            ),
          // Extra space for future options
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Future<void> _toggle(WidgetRef ref) async {
    final notifier = ref.read(shoppingItemsProvider.notifier);
    final key = '${item.name.toLowerCase()}|${item.unit.toLowerCase()}';

    final current = ref.read(shoppingItemsProvider).valueOrNull ?? [];
    final existing = current.where(
      (c) => '${c.name.toLowerCase()}|${c.unit.toLowerCase()}' == key,
    );

    if (existing.isNotEmpty) {
      await notifier.toggleChecked(existing.first.id);
    } else {
      await notifier.upsert(ShoppingItem(
        id: _uuid.v4(),
        name: item.name,
        amount: item.amount,
        unit: item.unit,
        category: item.category,
        isChecked: true,
        source: item.source,
      ));
    }
  }

  Future<void> _toggleUnavailable(WidgetRef ref) async {
    final notifier = ref.read(shoppingItemsProvider.notifier);
    final key = '${item.name.toLowerCase()}|${item.unit.toLowerCase()}';

    final current = ref.read(shoppingItemsProvider).valueOrNull ?? [];
    final existing = current.where(
      (c) => '${c.name.toLowerCase()}|${c.unit.toLowerCase()}' == key,
    );

    if (existing.isNotEmpty) {
      await notifier.toggleUnavailable(existing.first.id);
    } else {
      await notifier.upsert(ShoppingItem(
        id: _uuid.v4(),
        name: item.name,
        amount: item.amount,
        unit: item.unit,
        category: item.category,
        isUnavailable: true,
        source: item.source,
      ));
    }
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

    // Parse "2x Milch" or "3 Eier" style input
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

    await ref.read(shoppingItemsProvider.notifier).upsert(item);
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

    return generalAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorRetryWidget(
        message: 'Artikel konnten nicht geladen werden.',
        onRetry: () => ref.invalidate(generalItemsProvider),
      ),
      data: (items) {
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
                        itemBuilder: (context, index) =>
                            _GeneralItemTile(item: items[index]),
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
  const _GeneralItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountStr = item.amount == item.amount.roundToDouble()
        ? item.amount.toInt().toString()
        : item.amount.toStringAsFixed(1);

    final isExcluded = item.excludedThisTrip;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(generalItemsProvider.notifier).delete(item.id),
      child: ListTile(
        title: Text(
          item.name,
          style: isExcluded
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: PaperTheme.checked,
                )
              : null,
        ),
        subtitle: Text('$amountStr ${item.unit}'.trim()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.category.isNotEmpty) ...[
              Chip(
                label: Text(item.category),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              const SizedBox(width: 4),
            ],
            Tooltip(
              message: isExcluded
                  ? 'Wieder auf die Liste'
                  : 'Diesmal ausschließen',
              child: IconButton(
                icon: Icon(
                  isExcluded
                      ? Icons.remove_shopping_cart
                      : Icons.remove_shopping_cart_outlined,
                  color: isExcluded ? PaperTheme.error : PaperTheme.checked,
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () => ref
                    .read(generalItemsProvider.notifier)
                    .toggleExcluded(item.id),
              ),
            ),
          ],
        ),
        onTap: () => _editItem(context, ref),
      ),
    );
  }

  Future<void> _editItem(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (_) => _GeneralItemDialog(existing: item),
    );
    GeneralItem? edited;
    if (result is GeneralItem) {
      edited = result;
    } else if (result is (GeneralItem, bool)) {
      edited = result.$1;
    }
    if (edited != null) {
      await ref.read(generalItemsProvider.notifier).upsert(edited);
      await ref.read(ingredientCatalogProvider.notifier).learnIngredient(
            name: edited.name,
            unit: edited.unit,
            category: edited.category,
          );
      if (edited.unit.isNotEmpty) {
        await ref.read(unitsProvider.notifier).addUnit(edited.unit);
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
    bool keepGoing = true;
    while (keepGoing) {
      keepGoing = false;
      if (!context.mounted) return;
      final result = await showDialog<dynamic>(
        context: context,
        builder: (_) => const _GeneralItemDialog(),
      );
      GeneralItem? item;
      if (result is GeneralItem) {
        item = result;
      } else if (result is (GeneralItem, bool)) {
        item = result.$1;
        keepGoing = result.$2;
      }
      if (item != null) {
        await ref.read(generalItemsProvider.notifier).upsert(item);
        await ref.read(ingredientCatalogProvider.notifier).learnIngredient(
              name: item.name,
              unit: item.unit,
              category: item.category,
            );
        if (item.unit.isNotEmpty) {
          await ref.read(unitsProvider.notifier).addUnit(item.unit);
        }
      }
    }
  }
}

// ── Dialog for creating/editing a general item ──────────────────────

class _GeneralItemDialog extends ConsumerStatefulWidget {
  final GeneralItem? existing;
  final bool autoFocusName;
  const _GeneralItemDialog({this.existing, this.autoFocusName = true});

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
  late final FocusNode _nameFocus;
  late final FocusNode _amountFocus;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl =
        TextEditingController(text: e != null ? e.amount.toString() : '1');
    _unitCtrl = TextEditingController(text: e?.unit ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? '');
    _nameFocus = FocusNode();
    _amountFocus = FocusNode();
    if (widget.autoFocusName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nameFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _unitCtrl.dispose();
    _categoryCtrl.dispose();
    _nameFocus.dispose();
    _amountFocus.dispose();
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
                // Name with autocomplete
                RawAutocomplete<IngredientCatalogEntry>(
                  textEditingController: _nameCtrl,
                  focusNode: _nameFocus,
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
                    // Jump to amount field after selection
                    _amountFocus.requestFocus();
                  },
                  fieldViewBuilder:
                      (context, textCtrl, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: textCtrl,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Name *'),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Erforderlich'
                              : null,
                      onFieldSubmitted: (_) {
                        onFieldSubmitted();
                        _amountFocus.requestFocus();
                      },
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
                        focusNode: _amountFocus,
                        decoration:
                            const InputDecoration(labelText: 'Menge'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textInputAction: TextInputAction.next,
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
    // Collect unique categories from the catalog
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
        return KeyboardListener(
          focusNode: FocusNode(), // wrapper for Shift+Enter detection
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter &&
                HardwareKeyboard.instance.isShiftPressed) {
              _submitAndContinue();
            }
          },
          child: TextFormField(
            controller: textCtrl,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Kategorie (optional)',
              helperText: 'Shift+Enter = Speichern & Weiter',
            ),
            onFieldSubmitted: (_) => onFieldSubmitted(),
          ),
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

  /// Save current item and signal caller to reopen the dialog.
  void _submitAndContinue() {
    if (!_formKey.currentState!.validate()) return;

    final item = GeneralItem(
      id: widget.existing?.id ?? _uuid.v4(),
      name: _nameCtrl.text.trim(),
      amount: double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 1,
      unit: _unitCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
    );

    // Pop with a record: (item, continue: true)
    Navigator.of(context).pop((item, true));
  }
}

// ── Quick edit dialog for shopping items (amount/unit/name) ───────

class _ShoppingItemEditDialog extends StatefulWidget {
  final ShoppingItem item;
  const _ShoppingItemEditDialog({required this.item});

  @override
  State<_ShoppingItemEditDialog> createState() =>
      _ShoppingItemEditDialogState();
}

class _ShoppingItemEditDialogState extends State<_ShoppingItemEditDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _unitCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.name);
    _amountCtrl = TextEditingController(
      text: widget.item.amount == widget.item.amount.roundToDouble()
          ? widget.item.amount.toInt().toString()
          : widget.item.amount.toString(),
    );
    _unitCtrl = TextEditingController(text: widget.item.unit);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Menge bearbeiten'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _amountCtrl,
                  decoration: const InputDecoration(labelText: 'Menge'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _unitCtrl,
                  decoration: const InputDecoration(labelText: 'Einheit'),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () {
            final updated = widget.item.copyWith(
              name: _nameCtrl.text.trim(),
              amount:
                  double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ??
                      widget.item.amount,
              unit: _unitCtrl.text.trim(),
            );
            Navigator.of(context).pop(updated);
          },
          child: const Text('Speichern'),
        ),
      ],
    );
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
