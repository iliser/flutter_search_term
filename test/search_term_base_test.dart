import 'package:flutter_test/flutter_test.dart';

import 'package:search_term/search_term/search_term.dart';

void _test(
  Type termType,
  SearchTerm Function() _new,
  SearchTerm Function(Map<String, dynamic> json) fromJson,
) {
  group(
    termType.toString(),
    () {
      test('toJson is implemented and don\'t throw', () {
        expect(() => _new().toJson(), returnsNormally);
      });

      test('fromJson is implemented and don\'t throw', () {
        expect(() => fromJson(_new().toJson()), returnsNormally);
      });

      test('equals operator works fine', () {
        expect(_new() == _new(), true);
      });

      test('equals works after toJson -> fromJson', () {
        final val = _new();
        expect(val == fromJson(val.toJson()), true);
      });

      test('hashCode equal after toJson -> fromJson', () {
        final val = _new();
        expect(val.hashCode, fromJson(val.toJson()).hashCode);
      });
    },
  );
}

void main() {
  _test(
    PatternSearchTerm,
    () => PatternSearchTerm(RegExp('v')),
    PatternSearchTerm.fromJson,
  );

  _test(
    TagSearchTerm,
    () => TagSearchTerm({'value'}),
    TagSearchTerm.fromJson,
  );

  _test(
    ProxySearchTerm,
    () => TagSearchTerm({'value'}).proxy,
    ProxySearchTerm.fromJson,
  );

  _test(
    CombinedSearchTerm,
    () => CombinedSearchTerm()..add(TagSearchTerm({'value'})),
    CombinedSearchTerm.fromJson,
  );

  _test(
    RangeSearchTerm<ValueSearchable, DateTime>,
    () => RangeSearchTerm<ValueSearchable, DateTime>(),
    RangeSearchTerm.fromJson,
  );

  _test(
    RangeSearchTerm<ValueSearchable, int>,
    () => RangeSearchTerm<ValueSearchable, int>(),
    RangeSearchTerm.fromJson,
  );

  _test(
    RangeSearchTerm<ValueSearchable, double>,
    () => RangeSearchTerm<ValueSearchable, double>(),
    RangeSearchTerm.fromJson,
  );

  test('throw error on incorrect json type', () {
    expect(
      () => SearchTerm.fromJson({}),
      throwsA(anything),
    );
    expect(
      () => SearchTerm.fromJson({'termType': 'incorect'}),
      throwsA(anything),
    );
  });
}
