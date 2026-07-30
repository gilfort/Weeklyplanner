# Meal Planner — Validation & Improvement Backlog

*Generated 2026-07-30. Baseline: uncommitted working tree on `main` (derived-shopping-list refactor + Google Drive sync).*

## Current State (Validation)

| Check | Result |
|---|---|
| `flutter analyze` | ✅ 3 info-level issues only (`unintended_html_in_doc_comment` in `lib/config/google_drive_config.dart:12,15`) |
| `flutter test` | ✅ 34/34 tests pass (models, providers, repositories, recipe-list widgets) |
| Architecture | ✅ Clean: freezed models → JSON repositories → pluggable `StorageBackend` (file / web / Drive / cached-sync) → Riverpod providers → screens |
| Git hygiene | ⚠️ Large refactor (shopping state → derived provider, Drive sync, Windows support) entirely uncommitted on `main` |
| Metadata | ⚠️ `pubspec.yaml` description still "A new Flutter project", version `1.0.0+1`, Android package still `com.example.meal_planner` |
| Dependencies | ⚠️ Riverpod 2.x / freezed 2.x (3.x major versions available); legacy `AppRouterRef` typedefs |
| CI | ❌ None |

**Notable design facts:** shopping-list check state is keyed by `"name|unit"` strings in `WeekPlan.checkedKeys`; sync is offline-first with remote-wins-on-first-read + background push; Drive sync gated to Android only; UI is hardcoded German; single light "paper" theme.

---

## A. Technical Improvements

### A1. Commit & branch discipline
> As a developer, I want the current refactor committed in logical chunks so that I can bisect regressions and roll back the Drive sync independently of the shopping-list rework.

### A2. CI pipeline (GitHub Actions: analyze + test)
> As a developer, I want every push to run `flutter analyze` and `flutter test` automatically so that regressions are caught before they land on my devices.

### A3. Split `shopping_list_screen.dart` (1007 lines)
> As a developer, I want the shopping screen decomposed into widgets (tile, quick-add sheet, section header, FAB) so that I can find and change UI behavior without scrolling a 1000-line file.

### A4. Persist the sync dirty-queue
`CachedSyncStorageBackend._dirty` is in-memory only — if the app is killed while offline, pending local writes are never pushed and the next remote-wins read **silently overwrites them**.
> As a user, I want edits made offline to survive an app restart and still sync later so that I never lose a week plan I edited on the train.

### A5. Conflict safety beyond last-write-wins
> As a two-device household, we want concurrent edits (partner checks items in the store while I edit the plan at home) merged or at least detected so that one device doesn't silently erase the other's changes.

### A6. Stable ingredient identity for check state
`checkedKeys` uses `"name|unit"` — renaming an ingredient in a recipe or changing its unit resets/orphans checked state and amount overrides.
> As a user, I want my checked-off items to stay checked when a recipe gets a small edit so that I don't re-tick half my list mid-shopping.

### A7. Router deep-link guard
`/recipes/:id/edit` does `ref.read(recipesProvider).valueOrNull ?? []` at build time — on a cold deep link recipes aren't loaded yet, so the edit screen silently opens as "new recipe".
> As a user, I want a recipe link opened from cold start to show that recipe (or a loading/error state) so that I don't accidentally create a duplicate.

### A8. Test the sync layer
No tests for `CachedSyncStorageBackend`, Drive backend, or the shopping-list screen.
> As a developer, I want unit tests around offline-first read/write/push ordering so that sync bugs (the class most likely to destroy data) are caught in CI, not in production.

### A9. Upgrade Riverpod 3 / freezed 3, fix doc-comment lints
> As a developer, I want dependencies on current majors so that I keep receiving fixes and new codegen stays compatible with future Flutter SDKs.

### A10. Real application ID + pubspec metadata
> As a user, I want the app to have a proper package ID and version so that Play-Store installs, OAuth client bindings, and upgrades work reliably (Google OAuth is bound to package name + SHA — `com.example.*` will block release).

### A11. Secrets/config hygiene for `google_drive_config.dart`
> As a developer, I want OAuth client IDs in a gitignored or env-injected config so that publishing the repo never leaks project credentials.

---

## B. UI/UX Improvements

### B1. Dark mode
> As an evening user, I want a dark theme so that checking the shopping list in a dim supermarket or planning at night doesn't blind me.

### B2. Localization (l10n) instead of hardcoded German
> As a non-German-speaking household member, I want the app language to follow my device locale so that I can use the shared plan too.

### B3. Group shopping list by category/aisle
`Ingredient.category` already exists — surface it.
> As a shopper, I want items grouped by category (produce, dairy, …) in store order so that I walk the supermarket once instead of zig-zagging.

### B4. Week overview at a glance
Current week screen is expandable day sections.
> As a planner, I want a compact 7-day grid view so that I can see the whole week's meals without expanding each day.

### B5. Copy last week / week templates
> As a busy planner, I want to duplicate a previous week (or save a template week) so that recurring routines take one tap instead of 28 slot assignments.

### B6. Drag & drop meals between slots
> As a planner, I want to drag a meal from Tuesday dinner to Thursday lunch so that reshuffling the week feels effortless.

### B7. Recipe search + tag filter
> As a cook with a growing collection, I want to search recipes by name and filter by tag so that I find "quick" weeknight meals in seconds.

### B8. Undo snackbar for destructive actions
> As a user, I want an Undo after deleting a recipe or unchecking-all so that a slip of the finger isn't permanent.

### B9. Show sync status
> As a Drive-sync user, I want a subtle indicator (synced / pending / offline) so that I know whether my partner's phone already sees my changes.

### B10. Larger touch targets & swipe actions on shopping list
> As a shopper with a cart in one hand, I want swipe-to-check and big tap areas so that I can operate the list one-thumbed.

---

## C. Feature Ideas

### C1. Recipe instructions & photos
Recipe has only name/description/ingredients today.
> As a cook, I want step-by-step instructions and a photo per recipe so that the app replaces my recipe binder, not just my shopping notepad.

### C2. Unit-aware aggregation
`500 g` + `1 kg` currently stay two lines (key = name|unit).
> As a shopper, I want amounts in compatible units merged (1.5 kg) so that the list tells me the real total to buy.

### C3. Share/export shopping list
> As a household member, I want to share the list as text (WhatsApp/clipboard) so that whoever happens to be near the store can shop without the app.

### C4. Drive sync on Windows/desktop
Currently `driveAvailable = Android only`.
> As a desktop planner, I want the same Drive sync on Windows so that I plan on the PC and shop with the phone against one dataset.

### C5. Full data backup/restore (JSON export/import)
> As a data owner, I want one-tap export/import of all recipes and plans so that switching devices or recovering from a bad sync is safe.

### C6. Recipe import from URL
> As a cook, I want to paste a recipe website link and get a pre-filled recipe so that building my collection doesn't mean retyping ingredients.

### C7. Meal suggestions / "surprise me"
> As an uninspired planner, I want a suggestion button that proposes recipes I haven't cooked recently (respecting tags) so that filling empty slots is fun instead of a chore.

### C8. Leftover & eating-out markers
> As a realistic planner, I want to mark a slot as "leftovers" or "eating out" so that the plan reflects reality and the shopping list doesn't over-buy.

### C9. Pantry check-off ("already have it")
`unavailableKeys` exists; extend to a pantry concept.
> As a shopper, I want to mark items as "in stock at home" during planning so that the list only contains what I actually need to buy.

### C10. Nutrition / serving info per recipe
> As a health-conscious user, I want optional calories/macros per recipe so that I can balance the week at planning time.

---

## Suggested priority

1. **Data safety first:** A4 (persist dirty queue), A6 (stable check keys), A1 (commit), A2 (CI), A8 (sync tests)
2. **Daily-use wins:** B3 (category grouping), B5 (copy week), C2 (unit merge), B8 (undo), C3 (share list)
3. **Release readiness:** A10 (app id), A11 (secrets), B1 (dark mode), B2 (l10n)
4. **Delight:** C1 (instructions/photos), B6 (drag & drop), C6 (URL import), C7 (suggestions)
