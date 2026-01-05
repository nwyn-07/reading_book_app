class ReadingStatsItem {
  final DateTime date;
  final int totalDurationSeconds;
  final int storiesReadCount;

  ReadingStatsItem({
    required this.date,
    required this.totalDurationSeconds,
    required this.storiesReadCount,
  });

  factory ReadingStatsItem.fromJson(Map<String, dynamic> json) {
    return ReadingStatsItem(
      date: DateTime.parse(json['date']),
      totalDurationSeconds: json['totalDurationSeconds'] ?? 0,
      storiesReadCount: json['storiesReadCount'] ?? 0,
    );
  }
}
