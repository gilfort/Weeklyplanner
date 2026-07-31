import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/sync/three_way_merge.dart';

void main() {
  group('mergeValue', () {
    test('keeps the value when nobody changed it', () {
      expect(mergeValue('a', 'a', 'a', preferRemote: false), 'a');
    });

    test('takes the side that changed', () {
      expect(mergeValue('a', 'b', 'a', preferRemote: true), 'b');
      expect(mergeValue('a', 'a', 'c', preferRemote: false), 'c');
    });

    test('accepts identical changes from both sides', () {
      expect(mergeValue('a', 'b', 'b', preferRemote: false), 'b');
    });

    test('falls back to the newer side only on a real conflict', () {
      expect(mergeValue('a', 'b', 'c', preferRemote: false), 'b');
      expect(mergeValue('a', 'b', 'c', preferRemote: true), 'c');
    });

    test('uses the supplied equality for lists', () {
      final base = ['x'];
      final local = ['x']; // equal content, different identity
      final remote = ['x', 'y'];

      // Without structural equality both sides would look changed and the
      // remote addition could be dropped.
      expect(
        mergeValue(base, local, remote,
            preferRemote: false, equals: listEquals),
        ['x', 'y'],
      );
    });
  });

  group('listEquals', () {
    test('compares element by element', () {
      expect(listEquals([1, 2], [1, 2]), isTrue);
      expect(listEquals([1, 2], [2, 1]), isFalse);
      expect(listEquals([1], [1, 2]), isFalse);
      expect(listEquals<int>([], []), isTrue);
    });
  });

  group('mergeSet', () {
    test('keeps additions from both sides', () {
      expect(mergeSet({'a'}, {'a', 'b'}, {'a', 'c'}), {'a', 'b', 'c'});
    });

    test('honours a removal even though the other side still has it', () {
      // The other side is not "keeping" it, it just hasn't seen the removal.
      expect(mergeSet({'a', 'b'}, {'a', 'b'}, {'a'}), {'a'});
    });

    test('handles check and uncheck in the same round', () {
      // At home: ticked b. In the shop: un-ticked a. Both must survive.
      final result = mergeSet({'a'}, {'a', 'b'}, <String>{});
      expect(result, {'b'});
    });

    test('a removal on both sides stays removed', () {
      expect(mergeSet({'a', 'b'}, {'a'}, {'a'}), {'a'});
    });

    test('is order independent', () {
      const base = {'a', 'b'};
      const local = {'a', 'c'};
      const remote = {'b'};
      expect(mergeSet(base, local, remote), mergeSet(base, remote, local));
    });

    test('does not mutate its inputs', () {
      final base = {'a', 'b'};
      mergeSet(base, {'a'}, {'a', 'c'});
      expect(base, {'a', 'b'});
    });
  });

  group('mergeMap', () {
    test('keeps additions from both sides', () {
      final result = mergeMap(
        {'k': 1},
        {'k': 1, 'l': 2},
        {'k': 1, 'r': 3},
        preferRemote: false,
      );
      expect(result, {'k': 1, 'l': 2, 'r': 3});
    });

    test('takes the changed value from whichever side changed it', () {
      expect(
        mergeMap({'k': 1}, {'k': 2}, {'k': 1}, preferRemote: true),
        {'k': 2},
      );
    });

    test('newer side wins when both changed the same key', () {
      expect(mergeMap({'k': 1}, {'k': 2}, {'k': 3}, preferRemote: true),
          {'k': 3});
      expect(mergeMap({'k': 1}, {'k': 2}, {'k': 3}, preferRemote: false),
          {'k': 2});
    });

    test('an untouched key deleted on one side stays deleted', () {
      expect(
        mergeMap({'k': 1}, {'k': 1}, <String, int>{}, preferRemote: false),
        isEmpty,
      );
    });

    test('an edit beats a concurrent delete', () {
      // Losing the partner's edit is worse than a delete they can repeat.
      expect(
        mergeMap({'k': 1}, {'k': 9}, <String, int>{}, preferRemote: true),
        {'k': 9},
      );
    });

    test('delegates a two-sided change to mergeEntry', () {
      final result = mergeMap(
        {'k': 1},
        {'k': 2},
        {'k': 3},
        preferRemote: false,
        mergeEntry: (b, l, r, _) => b + l + r,
      );
      expect(result, {'k': 6});
    });
  });

  group('mergeListByKey', () {
    test('merges by key, not by position', () {
      final result = mergeListByKey<String, String>(
        ['a:1'],
        ['a:1', 'b:1'],
        ['a:2'],
        keyOf: (v) => v.split(':').first,
        preferRemote: false,
      );
      expect(result, unorderedEquals(['a:2', 'b:1']));
    });
  });

  group('mergeDeletion', () {
    test('stays alive when neither side deleted', () {
      final r = mergeDeletion(
        localDeleted: false,
        localDeletedAt: null,
        remoteDeleted: false,
        remoteDeletedAt: null,
      );
      expect(r.deleted, isFalse);
      expect(r.deletedAt, isNull);
    });

    test('a deletion on one side wins over a concurrent edit', () {
      final at = DateTime.utc(2026, 5, 1);
      final r = mergeDeletion(
        localDeleted: false,
        localDeletedAt: null,
        remoteDeleted: true,
        remoteDeletedAt: at,
      );
      expect(r.deleted, isTrue);
      expect(r.deletedAt, at);
    });

    test('keeps the earliest timestamp when both deleted', () {
      final early = DateTime.utc(2026, 5, 1);
      final late = DateTime.utc(2026, 5, 9);
      final r = mergeDeletion(
        localDeleted: true,
        localDeletedAt: late,
        remoteDeleted: true,
        remoteDeletedAt: early,
      );
      expect(r.deletedAt, early);
    });
  });
}
