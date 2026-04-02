import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/unit_repository.dart';
import 'repository_providers.dart';

part 'unit_provider.g.dart';

@Riverpod(keepAlive: true)
class Units extends _$Units {
  late UnitRepository _repo;

  @override
  Future<List<String>> build() async {
    _repo = ref.watch(unitRepositoryProvider);
    return _repo.readAll();
  }

  Future<void> addUnit(String unit) async {
    await _repo.addUnit(unit);
    state = AsyncData(await _repo.readAll());
  }

  Future<void> removeUnit(String unit) async {
    await _repo.removeUnit(unit);
    state = AsyncData(await _repo.readAll());
  }
}
