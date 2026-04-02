import 'package:freezed_annotation/freezed_annotation.dart';

part 'shopping_item.freezed.dart';
part 'shopping_item.g.dart';

enum ShoppingSource {
  recipe,
  general,
  merged,
}

@freezed
abstract class ShoppingItem with _$ShoppingItem {
  const factory ShoppingItem({
    required String id,
    required String name,
    @Default(1.0) double amount,
    @Default('') String unit,
    @Default('') String category,
    @Default(false) bool isChecked,
    @Default(false) bool isUnavailable,
    @Default(ShoppingSource.general) ShoppingSource source,
  }) = _ShoppingItem;

  factory ShoppingItem.fromJson(Map<String, dynamic> json) =>
      _$ShoppingItemFromJson(json);
}
