import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic class for paginated query results
class PaginatedResult<T> {
  /// The items returned in this page
  final List<T> items;

  /// The last document snapshot for pagination
  /// Pass this to the next query to fetch the next page
  final DocumentSnapshot? lastDocument;

  /// Whether there are more items to fetch
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    this.lastDocument,
    required this.hasMore,
  });

  /// Create an empty result
  factory PaginatedResult.empty() => const PaginatedResult(
        items: [],
        lastDocument: null,
        hasMore: false,
      );

  /// Check if this is the first page (no lastDocument was provided to the query)
  bool get isFirstPage => lastDocument == null && items.isNotEmpty;

  /// Check if this is an empty result
  bool get isEmpty => items.isEmpty;
}
