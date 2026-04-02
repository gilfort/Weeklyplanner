import 'package:flutter/material.dart';

import '../models/models.dart';

/// A single cell in the week grid.
/// Shows a "+" icon when empty, or recipe name when filled.
class MealSlotCard extends StatelessWidget {
  final Recipe? recipe;
  final MealSlot? slot;
  final VoidCallback onTapEmpty;
  final VoidCallback onTapFilled;
  final VoidCallback? onToggleDone;

  const MealSlotCard({
    super.key,
    required this.recipe,
    required this.slot,
    required this.onTapEmpty,
    required this.onTapFilled,
    this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = slot == null || slot!.recipeId == null;
    final isDeleted = !isEmpty && recipe == null;

    return GestureDetector(
      onTap: isEmpty ? onTapEmpty : onTapFilled,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.all(4),
        child: isEmpty
            ? _buildEmpty(context)
            : isDeleted
                ? _buildDeleted(context)
                : _buildFilled(context),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Icon(
        Icons.add,
        size: 20,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  Widget _buildDeleted(BuildContext context) {
    return Center(
      child: Text(
        'Rezept\ngelöscht',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontStyle: FontStyle.italic,
              fontSize: 9,
            ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFilled(BuildContext context) {
    final name = recipe?.name ?? '?';
    final servings = slot?.servings ?? recipe?.servings ?? 0;
    final isDone = slot?.done ?? false;

    return Stack(
      children: [
        Opacity(
          opacity: isDone ? 0.5 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${servings}P',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
        // Done checkbox in top-right corner
        Positioned(
          top: -4,
          right: -4,
          child: SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isDone,
              onChanged: onToggleDone != null ? (_) => onToggleDone!() : null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
