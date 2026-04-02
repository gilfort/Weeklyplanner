import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/shopping_item.dart';
import '../repositories/shopping_state_repository.dart';
import 'repository_providers.dart';

part 'shopping_items_provider.g.dart';

@riverpod
class ShoppingItems extends _$ShoppingItems {
  late ShoppingStateRepository _repo;

  @override
  Future<List<ShoppingItem>> build() async {
    _repo = ref.watch(shoppingStateRepositoryProvider);
    return _repo.readAll();
  }

  Future<void> upsert(ShoppingItem item) async {
    await _repo.upsertItem(item);
    state = AsyncData(await _repo.readAll());
  }

  Future<void> delete(String id) async {
    await _repo.deleteItem(id);
    state = AsyncData(await _repo.readAll());
  }

  Future<void> toggleChecked(String id) async {
    await _repo.toggleChecked(id);
    state = AsyncData(await _repo.readAll());
  }

  Future<void> toggleUnavailable(String id) async {
    await _repo.toggleUnavailable(id);
    state = AsyncData(await _repo.readAll());
  }

  Future<void> clearChecked() async {
    await _repo.clearChecked();
    state = AsyncData(await _repo.readAll());
  }

  /// Full reset: removes checked AND unavailable items.
  Future<void> clearAll() async {
    await _repo.clearAll();
    state = AsyncData(await _repo.readAll());
  }
}
