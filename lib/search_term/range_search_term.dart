import 'search_term_base.dart';
import 'searchable_builder.dart';

abstract class ValueSearchable extends Searchable {
  E extractValue<T extends ValueSearchable, E>(T object);
}

class RangeSearchableHelper<E extends Comparable> {
  final Type type;
  final E max;
  final E min;

  final dynamic Function(E value) toJson;
  final E Function(dynamic json) fromJson;

  RangeSearchableHelper({
    required this.type,
    required this.max,
    required this.min,
    required this.toJson,
    required this.fromJson,
  });
}

class RangeSearchTerm<T extends ValueSearchable, E extends Comparable>
    extends SearchTerm<T> {
  static Map<String, RangeSearchableHelper> helpers = {
    (double).toString(): RangeSearchableHelper<double>(
      type: double,
      min: double.negativeInfinity,
      max: double.infinity,
      fromJson: (v) => (v as num).toDouble(),
      toJson: (v) => v,
    ),
    (int).toString(): RangeSearchableHelper<int>(
      type: int,
      min: -(1 << 63),
      max: 1 << 63,
      fromJson: (v) => (v as num).toInt(),
      toJson: (v) => v,
    ),
    (DateTime).toString(): RangeSearchableHelper<DateTime>(
      type: DateTime,
      min: DateTime(0),
      max: DateTime(3000),
      fromJson: (v) => DateTime.parse(v),
      toJson: (v) => v.toIso8601String(),
    ),
  };

  final E min;
  final E max;

  RangeSearchTerm({
    E? min,
    E? max,
  })  : max = max ?? helpers[E.toString()]!.max as E,
        min = min ?? helpers[E.toString()]!.min as E {
    assert(
      this.min.compareTo(this.max) <= 0,
      'max must be greater or eqqual than min',
    );
  }

  @override
  double getScore(T object) {
    final v = object.extractValue<T, E>(object);
    return (min.compareTo(v) <= 0 && max.compareTo(v) >= 0) ? 1 : 0;
  }

  static const staticTermType = 'RangeSearchTerm';

  @override
  Map<String, dynamic> toJson() {
    final helper = helpers[E.toString()]! as RangeSearchableHelper<E>;
    return {
      'termType': staticTermType,
      'valueType': E.toString(),
      'searchableType': T.toString(),
      'min': helper.toJson(min),
      'max': helper.toJson(max),
    };
  }

  static RangeSearchTerm fromJson(Map<String, dynamic> json) {
    if (json['termType'] == staticTermType) {
      return valueSearchableBuilder(
        json['searchableType'],
        <T extends ValueSearchable>() {
          return valueTypeBuilder<T>(
            json['valueType'],
            <E extends Comparable>() {
              final helper = helpers[E.toString()]!;
              final min = json['min'];
              final max = json['max'];
              return RangeSearchTerm<T, E>(
                min: min == null ? helper.fromJson(min) as E : null,
                max: max == null ? helper.fromJson(max) as E : null,
              );
            },
          );
        },
      ) as RangeSearchTerm;
    }
    throw SearchTermParseError(staticTermType, json);
  }

  @override
  bool operator ==(Object other) {
    if (other is RangeSearchTerm) {
      return min == other.min && max == other.max;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(runtimeType, min, max);
}

RangeSearchTerm valueTypeBuilder<T extends ValueSearchable>(
  String valueType,
  RangeSearchTerm<T, E> Function<E extends Comparable>() builder,
) {
  switch (valueType) {
    case "double":
      return builder<double>();
    case "int":
      return builder<int>();
    case "DateTime":
      return builder<DateTime>();
    default:
      throw 'unsuported value type';
  }
}
