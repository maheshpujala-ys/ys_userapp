/// Generic wrapper for Spring `PagedModel<T>` responses.
/// Backend shape: `{ "content": [...], "page": { ... } }`.
class PagedResponse<T> {
  const PagedResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final raw = json['content'];
    final List<T> items = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(itemFromJson)
            .toList(growable: false)
        : const [];
    final page = json['page'] is Map<String, dynamic>
        ? json['page'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return PagedResponse(
      content: items,
      pageNumber: (page['number'] as num?)?.toInt() ?? 0,
      pageSize: (page['size'] as num?)?.toInt() ?? items.length,
      totalElements: (page['totalElements'] as num?)?.toInt() ?? items.length,
      totalPages: (page['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  final List<T> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
}
