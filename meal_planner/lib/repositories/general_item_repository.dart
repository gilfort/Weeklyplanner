import '../models/general_item.dart';
import 'json_file_repository.dart';

class GeneralItemRepository extends JsonFileRepository<GeneralItem> {
  GeneralItemRepository({required super.storage})
      : super(fileName: 'general.json');

  @override
  GeneralItem fromJson(Map<String, dynamic> json) =>
      GeneralItem.fromJson(json);

  @override
  Map<String, dynamic> toJson(GeneralItem item) => item.toJson();

  Future<void> upsertItem(GeneralItem item) =>
      upsert(item, (i) => i.id);

  Future<bool> deleteItem(String id) =>
      deleteById(id, (i) => i.id);
}
