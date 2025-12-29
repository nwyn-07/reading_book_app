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
    final lastReadChapter = json['lastReadChapter'];

    if (lastReadChapter == null || lastReadChapter['id'] == null) {
      throw Exception('History item has no lastReadChapter');
    }

    return ReadingHistory(
      chapterId: lastReadChapter['id'] as String,
      lastPosition: json['lastPosition'] is int
          ? json['lastPosition']
          : int.tryParse('${json['lastPosition']}') ?? 0,
      totalTimeSeconds: json['totalTimeSeconds'] is int
          ? json['totalTimeSeconds']
          : int.tryParse('${json['totalTimeSeconds']}') ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
