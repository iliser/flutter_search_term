import 'search_term_base.dart';

abstract class PatternSearchable extends Searchable {
  List<String> get searchableText;
}

class PatternSearchTerm extends SearchTerm<PatternSearchable> {
  final RegExp pattern;

  PatternSearchTerm(this.pattern);

  @override
  double getScore(PatternSearchable object) {
    return object.searchableText
        .map((e) => pattern.allMatches(e))
        .map((e) => e.length)
        .fold(0, (pv, c) => pv + c);
  }

  static const staticTermType = 'PattermSearchTerm';

  factory PatternSearchTerm.fromJson(Map<String, dynamic> json) {
    if (json['termType'] == staticTermType) {
      return PatternSearchTerm(
        RegExp(
          json['pattern'],
          caseSensitive: (json['caseSensitive'] as bool?) ?? false,
          multiLine: (json['multiLine'] as bool?) ?? false,
        ),
      );
    }
    throw SearchTermParseError(staticTermType, json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'termType': staticTermType,
      'pattern': pattern.pattern,
      'caseSensitive': pattern.isCaseSensitive,
      'multiLine': pattern.isMultiLine,
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is PatternSearchTerm) {
      return other.pattern == pattern;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(runtimeType, pattern);
}
