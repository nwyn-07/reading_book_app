import 'package:reading_book_app/core/models/ReadingStatsItem.dart';

class ReadingStatsSummary {
  final int totalDurationSeconds;
  final int totalStories;
  final List<ReadingStatsItem> items;

  ReadingStatsSummary({
    required this.totalDurationSeconds,
    required this.totalStories,
    required this.items,
  });

  factory ReadingStatsSummary.fromItems(List<ReadingStatsItem> items) {
    return ReadingStatsSummary(
      totalDurationSeconds: items.fold(
        0,
        (sum, e) => sum + e.totalDurationSeconds,
      ),
      totalStories: items.fold(0, (sum, e) => sum + e.storiesReadCount),
      items: items,
    );
  }
}
