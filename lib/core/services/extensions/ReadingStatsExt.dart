import 'package:reading_book_app/core/models/ReadingStats.dart';

extension ReadingStatsExt on ReadingStats {
  /// Tổng phút đọc
  int get totalMinutes => (totalTimeSeconds / 60).round();

  /// Tổng giờ đọc
  double get totalHours => totalTimeSeconds / 3600;

  /// Dữ liệu chart (time)
  List<int> get chartTimes => items.map((e) => e.timeSeconds).toList();

  /// Label chart
  List<String> get chartLabels => items.map((e) => e.label).toList();
}
