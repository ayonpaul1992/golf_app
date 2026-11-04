/// Shared list metadata; preserves each endpoint's fields and summary values.
class HistoryPage {
  const HistoryPage(
      {required this.items,
      required this.page,
      required this.limit,
      required this.hasMore,
      this.summary = const {}});
  final List<Map<String, dynamic>> items;
  final int page;
  final int limit;
  final bool hasMore;
  final Map<String, dynamic> summary;

  factory HistoryPage.fromJson(Map<String, dynamic> json,
      {required int page, required int limit, bool storeCredit = false}) {
    final data = json['data'];
    final rows = storeCredit && data is Map ? data['history'] : data;
    if (rows is! List) throw const FormatException('Expected a history list');
    final items = rows.map((item) {
      if (item is! Map) throw const FormatException('Invalid history record');
      return Map<String, dynamic>.from(item);
    }).toList();
    final count = json['count'];
    final filteredCount = count is num ? count.toInt() : int.tryParse('$count');
    return HistoryPage(
      items: items,
      page: page,
      limit: limit,
      hasMore: items.isNotEmpty &&
          (filteredCount != null
              ? page * limit < filteredCount
              : items.length >= limit),
      summary: Map<String, dynamic>.from(storeCredit && data is Map
          ? data
          : json['amount'] is Map
              ? json['amount']
              : {}),
    );
  }
}
