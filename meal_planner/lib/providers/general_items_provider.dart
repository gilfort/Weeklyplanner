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
    _repo = await ref.watch(generalItemRepositoryProvider.future);
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

  Future<void> toggleExcluded(String id) async {
    final items = await _repo.readAll();
    final idx = items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      final updated =
          items[idx].copyWith(excludedThisTrip: !items[idx].excludedThisTrip);
      await _repo.upsertItem(updated);
      state = AsyncData(await _repo.readAll());
    }
  }

  /// Reset all exclusions (e.g. when starting a new shopping trip).
  Future<void> resetExclusions() async {
    final items = await _repo.readAll();
    final updated = items
        .map((i) => i.excludedThisTrip ? i.copyWith(excludedThisTrip: false) : i)
        .toList();
    for (final item in updated) {
      await _repo.upsertItem(item);
    }
    state = AsyncData(await _repo.readAll());
  }
}
