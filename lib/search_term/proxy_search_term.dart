import 'search_term.dart';
import 'searchable_builder.dart';

class ProxySearchTerm<T extends Searchable> extends SearchTerm {
  final SearchTerm<T> term;

  ProxySearchTerm(this.term);

  @override
  double getScore(Searchable object) {
    if (object is T) {
      return term.getScore(object);
    }
    return 0;
  }

  static const staticTermType = 'ProxySearchTerm';
  String get templateType => T.toString();

  static ProxySearchTerm fromJson(Map<String, dynamic> json) {
    if (json['termType'] == staticTermType) {
      final term = SearchTerm.fromJson(json['term']);
      return searchableBuilder(
        json['templateType'],
        <T extends Searchable>() => ProxySearchTerm<T>(term as SearchTerm<T>),
      ) as ProxySearchTerm;
    }
    throw SearchTermParseError(staticTermType, json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'termType': staticTermType,
      'templateType': templateType,
      'term': term.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is ProxySearchTerm) {
      return term == other.term;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(runtimeType, term);
}

extension SearchTermProxyExtension<T extends Searchable> on SearchTerm<T> {
  SearchTerm get proxy {
    if (this is ProxySearchTerm) return this;
    return ProxySearchTerm(this);
  }
}
