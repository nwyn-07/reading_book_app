import 'package:reading_book_app/core/models/ReadingStatsItem.dart';

class ReadingStats {
  final int totalTimeSeconds;
  final int totalChapters;
  final int totalStories;
  final List<ReadingStatsItem> items;

  ReadingStats({
    required this.totalTimeSeconds,
    required this.totalChapters,
    required this.totalStories,
    required this.items,
  });

  factory ReadingStats.fromJson(Map<String, dynamic> json) {
    return ReadingStats(
      totalTimeSeconds: json['totalTimeSeconds'] ?? 0,
      totalChapters: json['totalChapters'] ?? 0,
      totalStories: json['totalStories'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => ReadingStatsItem.fromJson(e))
          .toList(),
    );
  }
}
