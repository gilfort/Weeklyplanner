import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/models.dart';
import 'package:meal_planner/sync/entity_merge.dart';
import 'package:meal_planner/sync/file_merge.dart';

void main() {
  SyncDecision<Recipe> decide({
    Recipe? local,
    Recipe? base,
    Recipe? remote,
    bool preferRemote = false,
  }) =>
      decideSync<Recipe>(
        local: local,
        base: base,
        remote: remote,
        preferRemote: preferRemote,
        merge: (b, l, r) =>
            mergeRecipe(b, l, r, preferRemote: preferRemote),
      );

  final pasta = Recipe(id: 'r1', name: 'Pasta', servings: 2);

  test('nothing on either side is a no-op', () {
    final d = decide();
    expect(d.outcome, SyncOutcome.absent);
    expect(d.merged, isNull);
    expect(d.writeLocal, isFalse);
    expect(d.writeRemote, isFalse);
  });

  test('a file only the remote has is pulled', () {
    final d = decide(remote: pasta);
    expect(d.outcome, SyncOutcome.pulled);
    expect(d.merged, pasta);
    expect(d.writeLocal, isTrue);
    expect(d.writeRemote, isFalse);
  });

  test('a never-uploaded local file is pushed', () {
    final d = decide(local: pasta);
    expect(d.outcome, SyncOutcome.pushed);
    expect(d.writeRemote, isTrue);
    expect(d.writeLocal, isFalse);
  });

  test('a remote file that vanished is pushed back, not deleted locally', () {
    // Deletions travel as tombstones inside the file, so a missing file is
    // never a delete.
    final d = decide(local: pasta, base: pasta);
    expect(d.outcome, SyncOutcome.pushed);
    expect(d.merged, pasta);
    expect(d.writeLocal, isFalse);
  });

  test('identical sides need no writes', () {
    final d = decide(local: pasta, base: pasta, remote: pasta);
    expect(d.outcome, SyncOutcome.inSync);
    expect(d.writeLocal, isFalse);
    expect(d.writeRemote, isFalse);
  });

  test('remote ahead, local untouched → fast-forward pull', () {
    final newer = pasta.copyWith(name: 'Penne');
    final d = decide(local: pasta, base: pasta, remote: newer);
    expect(d.outcome, SyncOutcome.pulled);
    expect(d.merged, newer);
    expect(d.writeLocal, isTrue);
    expect(d.writeRemote, isFalse);
  });

  test('local ahead, remote untouched → fast-forward push', () {
    final newer = pasta.copyWith(name: 'Penne');
    final d = decide(local: newer, base: pasta, remote: pasta);
    expect(d.outcome, SyncOutcome.pushed);
    expect(d.merged, newer);
    expect(d.writeRemote, isTrue);
    expect(d.writeLocal, isFalse);
  });

  test('both sides changed → three-way merge written to both', () {
    final d = decide(
      local: pasta.copyWith(name: 'Penne'),
      base: pasta,
      remote: pasta.copyWith(servings: 6),
    );

    expect(d.outcome, SyncOutcome.merged);
    expect(d.merged?.name, 'Penne');
    expect(d.merged?.servings, 6);
    expect(d.writeLocal, isTrue);
    expect(d.writeRemote, isTrue);
  });

  test('a merge equal to one side only writes the other', () {
    // Local already holds the merge result; only the remote needs updating.
    final local = pasta.copyWith(name: 'Penne', servings: 6);
    final d = decide(
      local: local,
      base: pasta,
      remote: pasta.copyWith(servings: 6),
    );

    expect(d.merged, local);
    expect(d.writeLocal, isFalse);
    expect(d.writeRemote, isTrue);
  });

  test('without a common ancestor the newer file wins wholesale', () {
    final local = pasta.copyWith(name: 'A');
    final remote = pasta.copyWith(name: 'B');

    final remoteWins = decide(local: local, remote: remote, preferRemote: true);
    expect(remoteWins.outcome, SyncOutcome.conflictResolved);
    expect(remoteWins.merged, remote);
    expect(remoteWins.writeLocal, isTrue);
    expect(remoteWins.writeRemote, isFalse);

    final localWins = decide(local: local, remote: remote);
    expect(localWins.merged, local);
    expect(localWins.writeRemote, isTrue);
    expect(localWins.writeLocal, isFalse);
  });

  test('the merged value is what both sides end up holding', () {
    // It doubles as the new base snapshot, so a second cycle must be a no-op.
    final first = decide(
      local: pasta.copyWith(name: 'Penne'),
      base: pasta,
      remote: pasta.copyWith(servings: 6),
    );
    final settled = first.merged!;

    final second = decide(local: settled, base: settled, remote: settled);
    expect(second.outcome, SyncOutcome.inSync);
    expect(second.writeLocal, isFalse);
    expect(second.writeRemote, isFalse);
  });
}
