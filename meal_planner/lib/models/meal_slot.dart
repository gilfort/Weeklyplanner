import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_slot.freezed.dart';
part 'meal_slot.g.dart';

@freezed
abstract class MealSlot with _$MealSlot {
  const factory MealSlot({
    String? recipeId,
    int? servings,
    @Default(false) bool done,
  }) = _MealSlot;

  factory MealSlot.fromJson(Map<String, dynamic> json) =>
      _$MealSlotFromJson(json);
}
