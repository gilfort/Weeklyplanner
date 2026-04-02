import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_week_provider.g.dart';

/// Returns the ISO week key for the current date, e.g. "2025-W14".
/// Kept as a simple provider so it can be overridden in tests.
@riverpod
class CurrentWeekKey extends _$CurrentWeekKey {
  @override
  String build() {
    final now = DateTime.now();
    final weekNumber = _isoWeekNumber(now);
    return '${now.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Manually set the week key (e.g. for navigation or tests).
  void set(String weekKey) {
    state = weekKey;
  }

  static int _isoWeekNumber(DateTime date) {
    // ISO 8601: week starts on Monday
    final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
    final jan1 = DateTime(thursday.year, 1, 1);
    return ((thursday.difference(jan1).inDays) / 7).ceil() + 1;
  }
}
