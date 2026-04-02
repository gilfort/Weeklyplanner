import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/general_item.dart';
import '../repositories/general_item_repository.dart';
import 'repository_providers.dart';

part 'general_items_provider.g.dart';

@riverpod
class GeneralItems extends _$GeneralItems {
  late GeneralItemRepository _repo;

  @override
  Future<List<GeneralItem>> build() async {
    _repo = ref.watch(generalItemRepositoryProvider);
    return _repo.readAll();
  }

  Future<void> upsert(GeneralItem item) async {
    await _repo.upsertItem(item);
    state = AsyncData(await _repo.readAll());
  }

  Future<void> delete(String id) async {
    await _repo.deleteItem(id);
    state = AsyncData(await _repo.readAll());
  }
}
