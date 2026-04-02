import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_item.freezed.dart';
part 'general_item.g.dart';

@freezed
abstract class GeneralItem with _$GeneralItem {
  const factory GeneralItem({
    required String id,
    required String name,
    @Default(1.0) double amount,
    @Default('') String unit,
    @Default('') String category,
  }) = _GeneralItem;

  factory GeneralItem.fromJson(Map<String, dynamic> json) =>
      _$GeneralItemFromJson(json);
}
