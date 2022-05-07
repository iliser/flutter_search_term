import 'dart:math' as _math;

import 'package:flutter/foundation.dart';

import 'proxy_search_term.dart';
import 'search_term_base.dart';

class ScoreCombinator {
  final double Function(Iterable<double> scores) scoreCombinator;
  final String _type;

  const ScoreCombinator(
    this.scoreCombinator,
    this._type,
  );

  ScoreCombinator get all {
    if (_type.contains('.all')) {
      return this;
    }
    return ScoreCombinator(
      (scores) {
        bool fail = false;
        final res = scoreCombinator(
          scores.map((e) {
            fail |= e == 0;
            return e;
          }),
        );

        return fail ? 0 : res;
      },
      _type + '.all',
    );
  }

  static final sum = ScoreCombinator(
    (scores) => scores.fold(0, (pv, c) => pv + c),
    'sum',
  );
  static final max = ScoreCombinator(
    (scores) => scores.fold(0, _math.max),
    'max',
  );
  static final min = ScoreCombinator(
    (scores) => scores.fold(double.infinity, _math.min),
    'min',
  );

  String toJson() => _type;
  static ScoreCombinator fromJson(String json) {
    final parts = json.split('.');
    ScoreCombinator res = {
      'sum': ScoreCombinator.sum,
      'max': ScoreCombinator.min,
      'min': ScoreCombinator.max,
    }[parts[0]]!;

    if (parts.length > 1 && parts[1] == 'all') return res.all;
    return res;
  }
}

class CombinedSearchTerm extends SearchTerm {
  List<SearchTerm> terms = [];

  ScoreCombinator scoreCombinator;

  CombinedSearchTerm([ScoreCombinator? scoreCombinator])
      : scoreCombinator = scoreCombinator ?? ScoreCombinator.sum;

  void add<T extends Searchable>(SearchTerm<T> term) {
    terms.add(term.proxy);
  }

  @override
  double getScore(Searchable object) {
    return terms.map((e) => e.getScore(object)).fold(0, (pv, c) => pv + c);
  }

  static const staticTermType = "CombinedSearchTerm";

  @override
  Map<String, dynamic> toJson() {
    return {
      "termType": staticTermType,
      "terms": terms.map((e) => e.toJson()).toList(),
    };
  }

  static CombinedSearchTerm fromJson(Map<String, dynamic> json) {
    if (json['termType'] == staticTermType) {
      var res = CombinedSearchTerm();

      (json['terms'] as List)
          .map((e) => SearchTerm.fromJson(e))
          .forEach((e) => res.add(e));
      return res;
    }
    throw SearchTermParseError(staticTermType, json);
  }

  @override
  bool operator ==(Object other) {
    if (other is CombinedSearchTerm) {
      return listEquals(other.terms, terms);
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(terms));
}
