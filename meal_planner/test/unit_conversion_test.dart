import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/models.dart';

void main() {
  group('unit families', () {
    test('metric mass units share a family', () {
      expect(unitsCompatible('g', 'kg'), isTrue);
      expect(unitsCompatible('KG', 'gramm'), isTrue);
    });

    test('volume units share a family', () {
      expect(unitsCompatible('ml', 'l'), isTrue);
      expect(unitsCompatible('cl', 'dl'), isTrue);
    });

    test('mass and volume never mix', () {
      expect(unitsCompatible('g', 'ml'), isFalse);
    });

    test('unknown units only match themselves', () {
      expect(unitsCompatible('Packung', 'Packung'), isTrue);
      expect(unitsCompatible('Packung', 'Dose'), isFalse);
      expect(unitsCompatible('Packung', 'g'), isFalse);
    });

    test('empty unit is its own family', () {
      expect(unitsCompatible('', ''), isTrue);
      expect(unitsCompatible('', 'Stk'), isFalse);
    });
  });

  group('AmountAccumulator', () {
    test('sums compatible units and scales up for display', () {
      final acc = AmountAccumulator()
        ..add(500, 'g')
        ..add(1, 'kg');

      final result = acc.build();
      expect(result.length, 1);
      expect(result.single.amount, 1.5);
      expect(result.single.unit, 'kg');
    });

    test('stays in the small unit below the threshold', () {
      final acc = AmountAccumulator()
        ..add(200, 'g')
        ..add(300, 'g');

      expect(acc.build().single, const ShoppingAmount(amount: 500, unit: 'g'));
    });

    test('keeps incompatible units side by side in insertion order', () {
      final acc = AmountAccumulator()
        ..add(500, 'g')
        ..add(2, 'Packung')
        ..add(250, 'g');

      final result = acc.build();
      expect(result.length, 2);
      expect(result[0], const ShoppingAmount(amount: 750, unit: 'g'));
      expect(result[1], const ShoppingAmount(amount: 2, unit: 'Packung'));
    });

    test('converts litres and millilitres', () {
      final acc = AmountAccumulator()
        ..add(250, 'ml')
        ..add(1, 'l');

      expect(acc.build().single, const ShoppingAmount(amount: 1.25, unit: 'l'));
    });

    test('is empty before anything is added', () {
      expect(AmountAccumulator().isEmpty, isTrue);
      expect(AmountAccumulator().build(), isEmpty);
    });
  });

  group('formatting', () {
    test('drops trailing zeros and uses a decimal comma', () {
      expect(formatAmount(2), '2');
      expect(formatAmount(2.0), '2');
      expect(formatAmount(1.5), '1,5');
      expect(formatAmount(0.25), '0,25');
    });

    test('rounds to two decimals', () {
      expect(formatAmount(1 / 3), '0,33');
    });

    test('omits an empty unit', () {
      expect(formatShoppingAmount(const ShoppingAmount(amount: 3)), '3');
      expect(
        formatShoppingAmount(const ShoppingAmount(amount: 1.5, unit: 'kg')),
        '1,5 kg',
      );
    });

    test('joins several amounts of one line', () {
      expect(
        formatAmounts(const [
          ShoppingAmount(amount: 1.5, unit: 'kg'),
          ShoppingAmount(amount: 2, unit: 'Packung'),
        ]),
        '1,5 kg + 2 Packung',
      );
    });
  });
}
