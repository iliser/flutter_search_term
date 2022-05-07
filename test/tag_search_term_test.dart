import 'package:flutter_test/flutter_test.dart';
import 'package:search_term/search_term/search_term.dart';

class Item extends TagSearchable {
  @override
  Set<String> get tags => {'tag1', 'tag2'};
}

void main() {
  test('single match', () {
    final i = Item();
    final q = TagSearchTerm({'tag1'});
    expect(q.getScore(i), 1);
  });
  test('no match', () {
    final i = Item();
    final q = TagSearchTerm({'tag'});
    expect(q.getScore(i), 0);
  });

  test('any combinator work', () {
    final i = Item();
    expect(TagSearchTerm({'tag1', 'tag'}).getScore(i), greaterThan(0));
    expect(TagSearchTerm({'tag'}).getScore(i), 0);
    expect(TagSearchTerm({'tag1', 'tag2'}).getScore(i), greaterThan(0));
  });

  test('all combinator work', () {
    final i = Item();
    expect(
      TagSearchTerm({'tag1', 'tag'}, TagSearchTerm.all).getScore(i),
      0,
    );
    expect(
      TagSearchTerm({'tag1', 'tag2'}, TagSearchTerm.all).getScore(i),
      1,
    );
  });

  test('json and internal is equal', () {
    final json = SearchTerm.fromJson({
      'termType': TagSearchTerm.staticTermType,
      'tag': ['item'],
    });

    final internal = TagSearchTerm({'item'});
    expect(
      json,
      internal,
    );
  });
}
