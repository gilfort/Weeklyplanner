import 'shopping_amount.dart';

/// Unit handling for the shopping list.
///
/// A shopping line is identified by its catalog id alone, so all contributions
/// to one ingredient land on the same line regardless of unit. Amounts that
/// share a *unit family* (mass, volume, count) are summed in a base unit and
/// shown in whichever unit of that family reads best; amounts in unrelated
/// units (`Packung`, `EL`, …) stay side by side on the same line.

/// Base unit + conversion factor for a known unit.
class _UnitSpec {
  final String familyKey;
  final String baseUnit;
  final double toBase;
  const _UnitSpec(this.familyKey, this.baseUnit, this.toBase);
}

const _mass = 'mass';
const _volume = 'volume';
const _count = 'count';

const Map<String, _UnitSpec> _knownUnits = {
  // mass, base gram
  'mg': _UnitSpec(_mass, 'g', 0.001),
  'g': _UnitSpec(_mass, 'g', 1),
  'gr': _UnitSpec(_mass, 'g', 1),
  'gramm': _UnitSpec(_mass, 'g', 1),
  'kg': _UnitSpec(_mass, 'g', 1000),
  'kilo': _UnitSpec(_mass, 'g', 1000),
  'kilogramm': _UnitSpec(_mass, 'g', 1000),
  // volume, base millilitre
  'ml': _UnitSpec(_volume, 'ml', 1),
  'cl': _UnitSpec(_volume, 'ml', 10),
  'dl': _UnitSpec(_volume, 'ml', 100),
  'l': _UnitSpec(_volume, 'ml', 1000),
  'liter': _UnitSpec(_volume, 'ml', 1000),
  'ltr': _UnitSpec(_volume, 'ml', 1000),
  // countable pieces
  'stk': _UnitSpec(_count, 'Stk', 1),
  'st': _UnitSpec(_count, 'Stk', 1),
  'stück': _UnitSpec(_count, 'Stk', 1),
  'stueck': _UnitSpec(_count, 'Stk', 1),
};

/// Larger units a family may be displayed in, biggest first.
const Map<String, List<MapEntry<String, double>>> _displayLadders = {
  _mass: [MapEntry('kg', 1000), MapEntry('g', 1)],
  _volume: [MapEntry('l', 1000), MapEntry('ml', 1)],
};

_UnitSpec _specFor(String unit) {
  final key = unit.trim().toLowerCase();
  final known = _knownUnits[key];
  if (known != null) return known;
  // Unknown or empty units are their own family and never merge with anything
  // else — "2 Packung" and "500 g" are not addable without a density table.
  return _UnitSpec('other:$key', unit.trim(), 1);
}

/// Family key two units must share to be summed together.
String unitFamilyKey(String unit) => _specFor(unit).familyKey;

/// True when [a] and [b] can be added into a single amount.
bool unitsCompatible(String a, String b) =>
    unitFamilyKey(a) == unitFamilyKey(b);

/// Converts [amount] of [unit] into the family's base unit.
double toBaseAmount(double amount, String unit) =>
    amount * _specFor(unit).toBase;

/// Picks the nicest unit of the family for [baseAmount]: 1500 g reads as
/// 1,5 kg, 800 g stays 800 g.
ShoppingAmount normalizeAmount(
  double baseAmount,
  String familyKey,
  String fallbackUnit,
) {
  final ladder = _displayLadders[familyKey];
  if (ladder == null) {
    return ShoppingAmount(amount: baseAmount, unit: fallbackUnit);
  }
  for (final step in ladder) {
    if (baseAmount.abs() >= step.value) {
      return ShoppingAmount(
        amount: baseAmount / step.value,
        unit: step.key,
      );
    }
  }
  final smallest = ladder.last;
  return ShoppingAmount(
    amount: baseAmount / smallest.value,
    unit: smallest.key,
  );
}

/// Formats a quantity for display: no trailing zeros, at most two decimals,
/// German decimal comma.
String formatAmount(double value) {
  final rounded = (value * 100).roundToDouble() / 100;
  if (rounded == rounded.roundToDouble()) return rounded.toInt().toString();
  return rounded
      .toStringAsFixed(2)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '')
      .replaceAll('.', ',');
}

/// "1,5 kg", or just "3" when the unit is empty.
String formatShoppingAmount(ShoppingAmount a) =>
    '${formatAmount(a.amount)} ${a.unit}'.trim();

/// Joins the amounts of one shopping line: "1,5 kg + 2 Packung".
String formatAmounts(List<ShoppingAmount> amounts) =>
    amounts.map(formatShoppingAmount).join(' + ');

/// Sums quantities of one shopping line, merging everything that shares a unit
/// family and keeping the rest side by side in insertion order.
class AmountAccumulator {
  final _baseTotals = <String, double>{};
  final _displayUnits = <String, String>{};
  final _order = <String>[];

  void add(double amount, String unit) {
    final spec = _specFor(unit);
    if (!_baseTotals.containsKey(spec.familyKey)) {
      _order.add(spec.familyKey);
      _displayUnits[spec.familyKey] = spec.baseUnit;
    }
    _baseTotals[spec.familyKey] =
        (_baseTotals[spec.familyKey] ?? 0) + amount * spec.toBase;
  }

  bool get isEmpty => _order.isEmpty;

  /// One [ShoppingAmount] per unit family, normalised for display.
  List<ShoppingAmount> build() => [
        for (final family in _order)
          normalizeAmount(
            _baseTotals[family]!,
            family,
            _displayUnits[family]!,
          ),
      ];
}
