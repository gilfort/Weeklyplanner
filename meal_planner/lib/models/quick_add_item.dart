import 'package:freezed_annotation/freezed_annotation.dart';

part 'quick_add_item.freezed.dart';
part 'quick_add_item.g.dart';

/// An ad-hoc shopping item added via quick-add. Scoped to one week.
///
/// Keyed by [catalogId] like everything else on the shopping list, so a
/// quick-added "Milch" merges into the line the week's recipes already
/// produced instead of showing up twice.
@freezed
abstract class QuickAddItem with _$QuickAddItem {
  const factory QuickAddItem({
    required String catalogId,
    @Default(1.0) double amount,
    @Default('') String unit,
  }) = _QuickAddItem;

  factory QuickAddItem.fromJson(Map<String, dynamic> json) =>
      _$QuickAddItemFromJson(json);
}
