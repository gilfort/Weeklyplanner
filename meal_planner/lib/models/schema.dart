/// Schema version written into every persisted JSON file.
///
/// Version 1 was the legacy layout: one collection file per entity type
/// (`recipes.json`, `weekplans.json`, …) with no version marker and
/// shopping-list state keyed by `"name|unit"` strings.
///
/// Version 2 is the sync rework layout: one file per entity
/// (`recipes/<id>.json`, `weeks/<weekKey>.json`, …), a `schemaVersion`
/// envelope around every payload, soft-deletes via `deleted`/`deletedAt`,
/// and shopping-list state keyed by stable catalog ids.
const int kSchemaVersion = 2;

/// How long a soft-deleted entity is kept before [EntityRepository.purgeTombstones]
/// may remove it. Tombstones must outlive the slowest device's sync interval by
/// a wide margin, otherwise a deletion could be resurrected by a stale peer.
const Duration kTombstoneRetention = Duration(days: 90);
