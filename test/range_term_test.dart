import 'package:flutter_test/flutter_test.dart';
import 'package:search_term/search_term/search_term.dart';

abstract class PriceSearchable extends ValueSearchable {}

class Item implements PriceSearchable {
  final double price;

  Item(this.price);
  @override
  E extractValue<T extends ValueSearchable, E>(T object) {
    if (T == PriceSearchable) {
      return price as E;
    }
    throw '_wtf';
  }
}

void main() {
  test('has match', () {
    final i = Item(100);
    final q = RangeSearchTerm<PriceSearchable, double>();
    expect(q.getScore(i), 1);
  });

  group('exactMatch', () {
    test('match min', () {
      final i = Item(100);
      final q = RangeSearchTerm<PriceSearchable, double>(min: 100);
      expect(q.getScore(i), 1);
    });
    test('match max', () {
      final i = Item(100);
      final q = RangeSearchTerm<PriceSearchable, double>(max: 100);
      expect(q.getScore(i), 1);
    });

    test('match both', () {
      final i = Item(100);
      final q = RangeSearchTerm<PriceSearchable, double>(min: 100, max: 100);
      expect(q.getScore(i), 1);
    });
  });

  group('notMatch', () {
    test('not match min', () {
      final i = Item(100);
      final q = RangeSearchTerm<PriceSearchable, double>(min: 101);
      expect(q.getScore(i), 0);
    });
    test('not match max', () {
      final i = Item(100);
      final q = RangeSearchTerm<PriceSearchable, double>(max: 99);
      expect(q.getScore(i), 0);
    });

    test('min max error', () {
      expect(
        () => RangeSearchTerm<PriceSearchable, double>(min: 110, max: 90),
        throwsAssertionError,
      );
    });
  });
}
