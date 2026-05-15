import 'package:expense_tracker_app/core/formatters/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyFormatter', () {
    test('formats zero correctly', () {
      expect(MoneyFormatter.format(0), '৳ 0');
    });

    test('formats simple amounts correctly', () {
      expect(MoneyFormatter.format(25000), '৳ 250');
    });

    test('formats lakh-style grouping correctly', () {
      expect(MoneyFormatter.format(14250000), '৳ 1,42,500');
    });

    test('formats large amounts correctly', () {
      expect(MoneyFormatter.format(1234567800), '৳ 12,34,56,780');
    });

    test('formats negative values with minus sign before symbol', () {
      expect(MoneyFormatter.format(-25000), '−৳ 250');
    });

    test('formats decimal values correctly (if any)', () {
      expect(MoneyFormatter.format(25050), '৳ 250.5');
    });
  });
}
