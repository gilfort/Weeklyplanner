import 'package:freezed_annotation/freezed_annotation.dart';

part 'shopping_amount.freezed.dart';
part 'shopping_amount.g.dart';

/// A quantity in one unit.
///
/// A shopping line holds one of these per unit *family* it could not merge
/// (`1,5 kg` and `2 Packung` stay separate amounts of the same line).
@freezed
abstract class ShoppingAmount with _$ShoppingAmount {
  const factory ShoppingAmount({
    required double amount,
    @Default('') String unit,
  }) = _ShoppingAmount;

  factory ShoppingAmount.fromJson(Map<String, dynamic> json) =>
      _$ShoppingAmountFromJson(json);
}
