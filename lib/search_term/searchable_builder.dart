import 'range_search_term.dart';
import 'search_term_base.dart';
import 'tag_search_term.dart';

SearchTerm searchableBuilder(
  String termType,
  SearchTerm Function<T extends Searchable>() builder,
) {
  switch (termType) {
    case 'Searchable':
      return builder();
    case 'TagSearchable':
      return builder<TagSearchable>();
    default:
      return valueSearchableBuilder(
        termType,
        builder as SearchTerm Function<T extends ValueSearchable>(),
      );
  }
}

late SearchTerm Function(
  String termType,
  SearchTerm Function<T extends ValueSearchable>() builder,
)? customValueSearchableBuilder;

SearchTerm valueSearchableBuilder(
  String termType,
  SearchTerm Function<T extends ValueSearchable>() builder,
) {
  switch (termType) {
    case 'ValueSearchable':
      return builder<ValueSearchable>();
  }
  if (customValueSearchableBuilder != null) {
    return customValueSearchableBuilder!.call(termType, builder);
  }
  throw 'Unsuported valueSearchableType';
}
