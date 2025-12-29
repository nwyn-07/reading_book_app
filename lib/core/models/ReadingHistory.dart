class ReadingHistory {
  final String chapterId;
  final int lastPosition;
  final int totalTimeSeconds;
  final DateTime updatedAt;

  ReadingHistory({
    required this.chapterId,
    required this.lastPosition,
    required this.totalTimeSeconds,
    required this.updatedAt,
  });

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    return ReadingHistory(
      chapterId: json['chapterId'],
      lastPosition: json['lastPosition'] ?? 0,
      totalTimeSeconds: json['totalTimeSeconds'] ?? 0,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
