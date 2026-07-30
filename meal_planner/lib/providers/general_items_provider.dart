import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/general_item.dart';
import '../repositories/general_item_repository.dart';
import 'repository_providers.dart';

part 'general_items_provider.g.dart';

@riverpod
class GeneralItems extends _$GeneralItems {
  Future<GeneralItemRepository> get _repo =>
      ref.read(generalItemRepositoryProvider.future);

  @override
  Future<List<GeneralItem>> build() async {
    final repo = await ref.watch(generalItemRepositoryProvider.future);
    return repo.readAll();
  }

  Future<void> upsert(GeneralItem item) async {
    final repo = await _repo;
    await repo.upsertItem(item);
    state = AsyncData(await repo.readAll());
  }

  Future<void> delete(String id) async {
    final repo = await _repo;
    await repo.deleteItem(id);
    state = AsyncData(await repo.readAll());
  }
}
