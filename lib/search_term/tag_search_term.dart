import 'package:flutter/foundation.dart';

import 'search_term_base.dart';

abstract class TagSearchable extends Searchable {
  Set<String> get tags;
}

enum _Combinator { any, all }

extension _CombinatorJson on _Combinator {
  String toJson() {
    return describeEnum(this);
  }

  static _Combinator fromJson(String value) {
    return _Combinator.values.firstWhere(
      (e) => value == describeEnum(e),
      orElse: () => TagSearchTerm.any,
    );
  }
}

class TagSearchTerm extends SearchTerm<TagSearchable> {
  final Set<String> tags;
  final _Combinator combinator;
  TagSearchTerm(this.tags, [this.combinator = _Combinator.any]);

  static const any = _Combinator.any;
  static const all = _Combinator.all;

  @override
  double getScore(TagSearchable object) {
    final cnt = object.tags.intersection(tags).length;
    switch (combinator) {
      case _Combinator.any:
        return cnt.toDouble();
      case _Combinator.all:
        return cnt == tags.length ? 1 : 0;
    }
  }

  static const staticTermType = 'TagSearchTerm';

  factory TagSearchTerm.fromJson(Map<String, dynamic> json) {
    if (json['termType'] == staticTermType) {
      return TagSearchTerm(
        (json['tag'] as List).cast<String>().toSet(),
        _CombinatorJson.fromJson(json['combinator'] ?? 'any'),
      );
    }
    throw SearchTermParseError(staticTermType, json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'termType': staticTermType,
      'tag': tags.toList(),
      'combinator': combinator.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is TagSearchTerm) {
      return combinator == other.combinator && setEquals(tags, other.tags);
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        combinator,
        Object.hashAll(tags),
      );
}
