import 'package:flutter_test/flutter_test.dart';
import 'package:search_term/search_term/search_term.dart';

class Item extends PatternSearchable {
  @override
  List<String> get searchableText => ['item1 item1', 'item2'];
}

void main() {
  test('single match', () {
    final i = Item();
    final q = PatternSearchTerm(RegExp('item2'));
    expect(q.getScore(i), 1);
  });
  test('multiple match', () {
    final i = Item();
    final q = PatternSearchTerm(RegExp('item'));
    expect(q.getScore(i), 3);
  });
  test('multiple match in one string', () {
    final i = Item();
    final q = PatternSearchTerm(RegExp('item1'));
    expect(q.getScore(i), 2);
  });
  test('no match', () {
    final i = Item();
    final q = PatternSearchTerm(RegExp('item3'));
    expect(q.getScore(i), 0);
  });

  test('json and internal is equal', () {
    final json = SearchTerm.fromJson({
      'termType': PatternSearchTerm.staticTermType,
      'pattern': 'item',
      'caseSensitive': true,
    });
    final internal = PatternSearchTerm(RegExp('item'));

    expect(
      json,
      internal,
    );
  });
}
