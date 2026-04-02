import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../models/ingredient.dart';
import '../models/ingredient_catalog_entry.dart';
import '../models/recipe.dart';
import '../providers/ingredient_catalog_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/unit_provider.dart';

const _uuid = Uuid();

class RecipeEditScreen extends ConsumerStatefulWidget {
  final Recipe? recipe;
  const RecipeEditScreen({super.key, this.recipe});

  @override
  ConsumerState<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends ConsumerState<RecipeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _servingsCtrl;
  late final TextEditingController _tagsCtrl;
  late final List<_IngredientRow> _ingredients;

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _servingsCtrl =
        TextEditingController(text: (r?.servings ?? 2).toString());
    _tagsCtrl = TextEditingController(text: r?.tags.join(', ') ?? '');
    _ingredients = r?.ingredients
            .map((i) => _IngredientRow.fromIngredient(i))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _servingsCtrl.dispose();
    _tagsCtrl.dispose();
    for (final row in _ingredients) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(ingredientCatalogProvider).valueOrNull ?? [];
    final units = ref.watch(unitsProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Rezept bearbeiten' : 'Neues Rezept'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name erforderlich' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _servingsCtrl,
              decoration: const InputDecoration(
                labelText: 'Portionen *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return (n == null || n <= 0) ? 'Mindestens 1' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                labelText: 'Tags (kommagetrennt)',
                border: OutlineInputBorder(),
                hintText: 'z.B. italienisch, schnell',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // ── Zutaten ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Zutaten',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () => _addIngredientRow(focusName: true),
                  icon: const Icon(Icons.add),
                  label: const Text('Zutat'),
                ),
              ],
            ),
            const Divider(),
            ..._ingredients.asMap().entries.map((e) {
              return _buildIngredientRow(
                e.value, e.key, catalog, units,
                isLast: e.key == _ingredients.length - 1,
              );
            }),
            if (_ingredients.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Noch keine Zutaten. Tippe auf „+ Zutat".',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(
    _IngredientRow row,
    int index,
    List<IngredientCatalogEntry> catalog,
    List<String> units, {
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Row 1: Name (autocomplete) + delete
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RawAutocomplete<IngredientCatalogEntry>(
                  textEditingController: row.nameCtrl,
                  focusNode: row.nameFocus,
                  optionsBuilder: (textEditingValue) {
                    final q = textEditingValue.text.trim().toLowerCase();
                    if (q.isEmpty) return const Iterable.empty();
                    return catalog
                        .where((e) => e.name.toLowerCase().contains(q));
                  },
                  displayStringForOption: (e) => e.name,
                  onSelected: (entry) {
                    if (entry.defaultUnit.isNotEmpty) {
                      row.unitCtrl.text = entry.defaultUnit;
                    }
                    if (entry.defaultCategory.isNotEmpty) {
                      row.categoryCtrl.text = entry.defaultCategory;
                    }
                    // Move focus to amount after selecting
                    row.amountFocus.requestFocus();
                    setState(() {});
                  },
                  fieldViewBuilder:
                      (context, textCtrl, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: textCtrl,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Zutat *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name erforderlich'
                          : null,
                      onFieldSubmitted: (_) {
                        onFieldSubmitted();
                        row.amountFocus.requestFocus();
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
                              maxHeight: 200, maxWidth: 300),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, i) {
                              final entry = options.elementAt(i);
                              final highlighted =
                                  AutocompleteHighlightedOption.of(context) ==
                                      i;
                              return Container(
                                color: highlighted
                                    ? Theme.of(context).focusColor
                                    : null,
                                child: ListTile(
                                  dense: true,
                                  title: Text(entry.name),
                                  subtitle: entry.defaultUnit.isNotEmpty
                                      ? Text(
                                          '${entry.defaultUnit}'
                                          '${entry.defaultCategory.isNotEmpty ? ' · ${entry.defaultCategory}' : ''}',
                                        )
                                      : null,
                                  onTap: () => onSelected(entry),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeIngredientRow(index),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2: Menge + Einheit + Kategorie
          Row(
            children: [
              SizedBox(
                width: 70,
                child: TextFormField(
                  controller: row.amountCtrl,
                  focusNode: row.amountFocus,
                  decoration: const InputDecoration(
                    labelText: 'Menge',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  validator: (v) {
                    final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                    return (n == null || n <= 0) ? '> 0' : null;
                  },
                  onFieldSubmitted: (_) => row.unitFocus.requestFocus(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: RawAutocomplete<String>(
                  textEditingController: row.unitCtrl,
                  focusNode: row.unitFocus,
                  optionsBuilder: (textEditingValue) {
                    final q = textEditingValue.text.trim().toLowerCase();
                    if (q.isEmpty) return units;
                    return units
                        .where((u) => u.toLowerCase().contains(q));
                  },
                  onSelected: (value) {
                    row.unitCtrl.text = value;
                    row.categoryFocus.requestFocus();
                  },
                  fieldViewBuilder:
                      (context, textCtrl, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: textCtrl,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Einheit',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        onFieldSubmitted();
                        row.categoryFocus.requestFocus();
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
                              maxHeight: 200, maxWidth: 150),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, i) {
                              final unit = options.elementAt(i);
                              final highlighted =
                                  AutocompleteHighlightedOption.of(context) ==
                                      i;
                              return Container(
                                color: highlighted
                                    ? Theme.of(context).focusColor
                                    : null,
                                child: ListTile(
                                  dense: true,
                                  title: Text(unit),
                                  onTap: () => onSelected(unit),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RawAutocomplete<String>(
                  textEditingController: row.categoryCtrl,
                  focusNode: row.categoryFocus,
                  optionsBuilder: (textEditingValue) {
                    final cats = <String>{
                      for (final e in catalog)
                        if (e.defaultCategory.isNotEmpty) e.defaultCategory,
                    }.toList()
                      ..sort();
                    final q = textEditingValue.text.trim().toLowerCase();
                    if (q.isEmpty) return cats;
                    return cats.where((c) => c.toLowerCase().contains(q));
                  },
                  onSelected: (value) {
                    row.categoryCtrl.text = value;
                    if (isLast) {
                      _addIngredientRow(focusName: true);
                    }
                  },
                  fieldViewBuilder:
                      (context, textCtrl, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: textCtrl,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Kategorie',
                        border: OutlineInputBorder(),
                        isDense: true,
                        hintText: 'z.B. Gemüse',
                      ),
                      textInputAction:
                          isLast ? TextInputAction.done : TextInputAction.next,
                      onFieldSubmitted: (_) {
                        onFieldSubmitted();
                        if (isLast) {
                          _addIngredientRow(focusName: true);
                        }
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
                              maxHeight: 200, maxWidth: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, i) {
                              final cat = options.elementAt(i);
                              final highlighted =
                                  AutocompleteHighlightedOption.of(context) ==
                                      i;
                              return Container(
                                color: highlighted
                                    ? Theme.of(context).focusColor
                                    : null,
                                child: ListTile(
                                  dense: true,
                                  title: Text(cat),
                                  onTap: () => onSelected(cat),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addIngredientRow({bool focusName = false}) {
    setState(() {
      _ingredients.add(_IngredientRow.empty());
    });
    if (focusName) {
      // Schedule focus request after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_ingredients.isNotEmpty) {
          _ingredients.last.nameFocus.requestFocus();
        }
      });
    }
  }

  void _removeIngredientRow(int index) {
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final ingredients = _ingredients.map((row) {
      return Ingredient(
        id: row.id,
        name: row.nameCtrl.text.trim(),
        amount: double.tryParse(row.amountCtrl.text.replaceAll(',', '.')) ?? 0,
        unit: row.unitCtrl.text.trim(),
        category: row.categoryCtrl.text.trim(),
      );
    }).toList();

    final recipe = Recipe(
      id: widget.recipe?.id ?? _uuid.v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      servings: int.tryParse(_servingsCtrl.text) ?? 2,
      ingredients: ingredients,
      tags: tags,
    );

    await ref.read(recipesProvider.notifier).upsert(recipe);

    final catalogNotifier = ref.read(ingredientCatalogProvider.notifier);
    for (final ing in ingredients) {
      await catalogNotifier.learnIngredient(
        name: ing.name,
        unit: ing.unit,
        category: ing.category,
      );
    }

    final unitsNotifier = ref.read(unitsProvider.notifier);
    for (final ing in ingredients) {
      if (ing.unit.isNotEmpty) {
        await unitsNotifier.addUnit(ing.unit);
      }
    }

    if (mounted) context.pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rezept löschen?'),
        content: Text('„${widget.recipe!.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(recipesProvider.notifier).delete(widget.recipe!.id);
      if (mounted) context.pop();
    }
  }
}

// ── Helper class to hold controllers + focus nodes for one ingredient row ──

class _IngredientRow {
  final String id;
  final TextEditingController nameCtrl;
  final TextEditingController amountCtrl;
  final TextEditingController unitCtrl;
  final TextEditingController categoryCtrl;
  final FocusNode nameFocus;
  final FocusNode amountFocus;
  final FocusNode unitFocus;
  final FocusNode categoryFocus;

  _IngredientRow({
    required this.id,
    required this.nameCtrl,
    required this.amountCtrl,
    required this.unitCtrl,
    required this.categoryCtrl,
    required this.nameFocus,
    required this.amountFocus,
    required this.unitFocus,
    required this.categoryFocus,
  });

  factory _IngredientRow.empty() => _IngredientRow(
        id: _uuid.v4(),
        nameCtrl: TextEditingController(),
        amountCtrl: TextEditingController(),
        unitCtrl: TextEditingController(),
        categoryCtrl: TextEditingController(),
        nameFocus: FocusNode(),
        amountFocus: FocusNode(),
        unitFocus: FocusNode(),
        categoryFocus: FocusNode(),
      );

  factory _IngredientRow.fromIngredient(Ingredient i) => _IngredientRow(
        id: i.id,
        nameCtrl: TextEditingController(text: i.name),
        amountCtrl: TextEditingController(text: i.amount.toString()),
        unitCtrl: TextEditingController(text: i.unit),
        categoryCtrl: TextEditingController(text: i.category),
        nameFocus: FocusNode(),
        amountFocus: FocusNode(),
        unitFocus: FocusNode(),
        categoryFocus: FocusNode(),
      );

  void dispose() {
    nameCtrl.dispose();
    amountCtrl.dispose();
    unitCtrl.dispose();
    categoryCtrl.dispose();
    nameFocus.dispose();
    amountFocus.dispose();
    unitFocus.dispose();
    categoryFocus.dispose();
  }
}
