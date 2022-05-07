export 'combined_search_term.dart';
export 'pattern_search_term.dart';
export 'proxy_search_term.dart';
export 'range_search_term.dart';
export 'search_term_base.dart';
export 'tag_search_term.dart';

import 'pattern_search_term.dart';
import 'proxy_search_term.dart';
import 'range_search_term.dart';
import 'tag_search_term.dart';

import 'search_term_base.dart';

SearchTerm searchTermFromJson(Map<String, dynamic> json) {
  const converters =
      <String, SearchTerm Function(Map<String, dynamic> dynamic)>{
    TagSearchTerm.staticTermType: TagSearchTerm.fromJson,
    PatternSearchTerm.staticTermType: PatternSearchTerm.fromJson,
    RangeSearchTerm.staticTermType: RangeSearchTerm.fromJson,
    ProxySearchTerm.staticTermType: ProxySearchTerm.fromJson,
  };
  final converter = converters[json['termType']];
  if (converter == null) throw SearchTermParseError('any', json);
  return converter(json);
}
