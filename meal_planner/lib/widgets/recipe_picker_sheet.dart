import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

/// Bottom sheet with a searchable recipe list for picking a recipe.
class RecipePickerSheet extends ConsumerStatefulWidget {
  const RecipePickerSheet({super.key});

  @override
  ConsumerState<RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends ConsumerState<RecipePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Rezept auswählen',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Suchen...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              ),
            ),

            const SizedBox(height: 8),

            // Recipe list
            Expanded(
              child: recipesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Fehler: $e')),
                data: (recipes) {
                  final filtered = _query.isEmpty
                      ? recipes
                      : recipes.where((r) {
                          return r.name.toLowerCase().contains(_query) ||
                              r.tags.any(
                                  (t) => t.toLowerCase().contains(_query));
                        }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Keine Rezepte gefunden.'),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final recipe = filtered[index];
                      return _RecipePickerTile(recipe: recipe);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecipePickerTile extends StatelessWidget {
  final Recipe recipe;
  const _RecipePickerTile({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(recipe.name),
      subtitle: recipe.tags.isNotEmpty
          ? Text(recipe.tags.join(', '))
          : null,
      trailing: Text('${recipe.servings} Port.'),
      onTap: () => Navigator.of(context).pop(recipe),
    );
  }
}
