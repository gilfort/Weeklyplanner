# Sync Rework — Design Decisions

*Agreed 2026-07-30 via grilling session. Replaces Google Drive API integration.*

## Goal

Provider-agnostic, serverless sync: all app data lives as plain JSON files that any
user-controlled storage (synced folder or WebDAV account) can carry. No paid APIs,
no OAuth verification, no backend.

## Decisions

| # | Topic | Decision |
|---|-------|----------|
| 1 | Platforms (v1) | **Android + Windows.** macOS later (same path as Windows), browser out of sync scope. |
| 2 | Transports | **Local-first + two sync target types:** (a) file-system folder — typically inside a Drive/OneDrive/Nextcloud desktop-sync directory; (b) built-in **WebDAV** client (Nextcloud, GMX, Koofr, MagentaCloud, Hetzner, …). App storage stays app-private; sync target is a copy the engine reconciles against. |
| 3 | Concurrency model | **Household, concurrent.** Partner checks items in store while planner edits at home — must merge, not overwrite. |
| 4 | File layout | **File per entity, everywhere.** `recipes/<id>.json`, `weeks/<weekKey>.json`, `general_items/<id>.json`, `catalog/<id>.json`, `units.json`(or per-unit). Minimal conflict blast radius. Requires directory listing + per-file change detection in every target. |
| 5 | Merge | **Three-way merge against stored base snapshot.** Each device persists last-synced version per file. Diff local↔base and remote↔base; auto-merge non-overlapping changes (correctly handles check *and* uncheck). |
| 6 | Deletions | **Soft-delete in the entity file** (`deleted: true`, `deletedAt`). No tombstone list, no resurrection ambiguity. Purge tombstones older than ~90 days. |
| 7 | Timing | **Foreground only:** pull on start/resume, debounced push after writes, manual refresh. No background workers in v1. |
| 8 | Check-state keys | **Issue #5 folds into this rework:** shopping check state moves from `"name|unit"` strings to stable ingredient IDs during the same schema change. One migration event, not two. |
| 9 | WebDAV setup | **Manual form:** URL + username + app-password. Credentials in `flutter_secure_storage` (Keystore/DPAPI), never in synced files. "Test connection" button. Docs recommend app-passwords. |
| 10 | Android folder mode | **Yes — SAF document tree as third target type** (covers e.g. Autosync-managed Google Drive folders). Accepted SAF caveats: revocable permissions, no change notifications, slower I/O. |
| 11 | Drive teardown | **Full removal, no migration.** Delete `google_sign_in`/`googleapis` deps, auth service, Drive backend, folder-picker dialog, Drive settings UI, OAuth config. Existing data is test-only — start fresh with new layout. |
| 12 | Conflict UX | **Silent newest-wins on genuine same-field overlap.** Log for debugging; no dialogs, no toasts. |

## Engine sketch

One `SyncTarget` contract, three implementations:

```
abstract class SyncTarget {
  Future<List<RemoteFile>> list(String dir);      // name + etag/mtime + size
  Future<String> read(String path);
  Future<void> write(String path, String content, {String? ifMatch}); // conditional where supported
  Future<void> delete(String path);
}
// Implementations: FolderSyncTarget (dart:io), SafSyncTarget (Android SAF), WebDavSyncTarget (http)
```

Per-file sync state (persisted locally): `baseSnapshot`, `remoteEtag`, `lastSyncedAt`.
"Needs push" = current ≠ baseSnapshot — derived, restart-safe, **no separate dirty queue**
(structurally fixes the old in-memory `_dirty` data-loss bug).

Sync cycle per file: compare local/base/remote → fast-forward pull, fast-forward push,
or three-way merge → write merged result both sides → update base + etag.

## Hygiene rules

- Every JSON file carries `schemaVersion` for future migrations.
- Folder/SAF writes: temp file + rename (atomic-ish); WebDAV writes: `If-Match` etag when server supports it, re-pull and re-merge on 412.
- Filenames are IDs (UUIDs / week keys) — no user text in paths.
- Old weeks naturally go cold; only active week files see concurrent writes.

## Effect on existing backlog

- Supersedes the shelved Drive items: dirty-queue persistence (structural fix), conflict
  handling (#three-way), secrets hygiene (no OAuth config left), Drive-on-Windows (moot).
- Folds in issue #5 (stable check keys).
- A "sync status indicator" (shelved earlier) becomes relevant again once engine exists — re-file later.
