import 'search_term.dart';

class SearchTermParseError extends Error {
  final String termType;
  final Map<String, dynamic> json;

  SearchTermParseError(this.termType, this.json) : super();

  @override
  String toString() {
    return 'SearchTermParseError expected termType : $termType json termType ${json['termType']}';
  }
}

abstract class Searchable {}

// requires
// - equal operator
// - fromJson,toJson implemented
// - _value == fromJson(toJson(_value))

abstract class SearchTerm<T extends Searchable> {
  const SearchTerm();

  double getScore(T object);

  bool Function(T object) get filter => (v) => getScore(v) > 0;

  static const staticTermType = 'TagSearchType';

  static SearchTerm fromJson(Map<String, dynamic> json) {
    return searchTermFromJson(json);
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  bool operator ==(Object other) {
    throw UnimplementedError();
  }

  @override
  int get hashCode {
    throw UnimplementedError();
  }
}
