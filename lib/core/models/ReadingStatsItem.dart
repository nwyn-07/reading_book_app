class ReadingStatsItem {
  final String label; // vd: "2025-09-22" | "09/2025" | "2025"
  final int timeSeconds;
  final int chapters;

  ReadingStatsItem({
    required this.label,
    required this.timeSeconds,
    required this.chapters,
  });

  factory ReadingStatsItem.fromJson(Map<String, dynamic> json) {
    return ReadingStatsItem(
      label: json['label'] ?? '',
      timeSeconds: json['timeSeconds'] ?? 0,
      chapters: json['chapters'] ?? 0,
    );
  }
}
