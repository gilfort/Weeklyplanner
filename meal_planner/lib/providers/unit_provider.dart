import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/unit_repository.dart';
import 'repository_providers.dart';

part 'unit_provider.g.dart';

@Riverpod(keepAlive: true)
class Units extends _$Units {
  Future<UnitRepository> get _repo => ref.read(unitRepositoryProvider.future);

  @override
  Future<List<String>> build() async {
    final repo = await ref.watch(unitRepositoryProvider.future);
    return repo.readAll();
  }

  Future<void> addUnit(String unit) async {
    final repo = await _repo;
    await repo.addUnit(unit);
    state = AsyncData(await repo.readAll());
  }

  Future<void> removeUnit(String unit) async {
    final repo = await _repo;
    await repo.removeUnit(unit);
    state = AsyncData(await repo.readAll());
  }
}
