import '../models/shopping_item.dart';
import 'json_file_repository.dart';

class ShoppingStateRepository extends JsonFileRepository<ShoppingItem> {
  ShoppingStateRepository({required super.storage})
      : super(fileName: 'shopping_state.json');

  @override
  ShoppingItem fromJson(Map<String, dynamic> json) =>
      ShoppingItem.fromJson(json);

  @override
  Map<String, dynamic> toJson(ShoppingItem item) => item.toJson();

  Future<void> upsertItem(ShoppingItem item) =>
      upsert(item, (i) => i.id);

  Future<bool> deleteItem(String id) =>
      deleteById(id, (i) => i.id);

  Future<void> toggleChecked(String id) async {
    final items = await readAll();
    final index = items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      items[index] = items[index].copyWith(isChecked: !items[index].isChecked);
      await writeAll(items);
    }
  }

  Future<void> toggleUnavailable(String id) async {
    final items = await readAll();
    final index = items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      items[index] = items[index].copyWith(
        isUnavailable: !items[index].isUnavailable,
      );
      await writeAll(items);
    }
  }

  Future<void> clearChecked() async {
    final items = await readAll();
    items.removeWhere((i) => i.isChecked);
    await writeAll(items);
  }

  /// Clears all checked AND unavailable items (full reset).
  Future<void> clearAll() async {
    final items = await readAll();
    items.removeWhere((i) => i.isChecked || i.isUnavailable);
    await writeAll(items);
  }
}
