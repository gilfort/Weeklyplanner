import 'package:freezed_annotation/freezed_annotation.dart';

import 'shopping_amount.dart';

part 'shopping_item.freezed.dart';
part 'shopping_item.g.dart';

enum ShoppingSource {
  recipe,
  general,
  merged,
}

/// One line of the shopping list. Purely derived — never persisted.
///
/// Identified by [catalogId]: every contribution to the same ingredient
/// (recipes, the general list, quick-adds) collapses into one line with one
/// checkbox. [amounts] holds one entry per unit family that could not be
/// merged, e.g. `1,5 kg` plus `2 Packung`.
@freezed
abstract class ShoppingItem with _$ShoppingItem {
  const ShoppingItem._();

  const factory ShoppingItem({
    required String catalogId,
    required String name,
    @Default('') String category,
    @Default(<ShoppingAmount>[]) List<ShoppingAmount> amounts,
    @Default(ShoppingSource.general) ShoppingSource source,

    /// True when a quick-add contributed to this line, which makes the line
    /// removable from the week without touching recipes or general items.
    @Default(false) bool hasQuickAdd,
  }) = _ShoppingItem;

  factory ShoppingItem.fromJson(Map<String, dynamic> json) =>
      _$ShoppingItemFromJson(json);
}
