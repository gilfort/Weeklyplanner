import '../models/general_item.dart';
import '../sync/entity_merge.dart';
import 'entity_repository.dart';

class GeneralItemRepository extends EntityRepository<GeneralItem> {
  GeneralItemRepository({required super.storage})
      : super(dirName: 'general_items');

  @override
  GeneralItem fromJson(Map<String, dynamic> json) => GeneralItem.fromJson(json);

  @override
  Map<String, dynamic> toJson(GeneralItem item) => item.toJson();

  @override
  String idOf(GeneralItem item) => item.id;

  @override
  bool isDeleted(GeneralItem item) => item.deleted;

  @override
  DateTime? deletedAtOf(GeneralItem item) => item.deletedAt;

  @override
  GeneralItem markDeleted(GeneralItem item, DateTime at) =>
      item.copyWith(deleted: true, deletedAt: at);

  @override
  GeneralItem merge(GeneralItem base, GeneralItem local, GeneralItem remote,
          {required bool preferRemote}) =>
      mergeGeneralItem(base, local, remote, preferRemote: preferRemote);

  Future<void> upsertItem(GeneralItem item) => upsert(item);

  Future<bool> deleteItem(String id) => delete(id);
}
