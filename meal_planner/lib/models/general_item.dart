import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_item.freezed.dart';
part 'general_item.g.dart';

/// An article the household always buys, independent of the week's recipes.
///
/// Identified by its [catalogId] — there is at most one general item per
/// ingredient, which keeps "excluded this week" and the shopping list's
/// checked state on the same key space as recipe ingredients.
@freezed
abstract class GeneralItem with _$GeneralItem {
  const GeneralItem._();

  const factory GeneralItem({
    required String catalogId,
    @Default(1.0) double amount,
    @Default('') String unit,
    @Default(false) bool deleted,
    DateTime? deletedAt,
  }) = _GeneralItem;

  /// Entity id for storage. General items are keyed by their catalog entry.
  String get id => catalogId;

  factory GeneralItem.fromJson(Map<String, dynamic> json) =>
      _$GeneralItemFromJson(json);
}
