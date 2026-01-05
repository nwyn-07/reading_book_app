import 'package:intl/intl.dart';
import 'package:reading_book_app/core/models/ReadingStatsSummary.dart';

extension ReadingStatsExt on ReadingStatsSummary {
  /// ⏱ Tổng phút đọc
  int get totalMinutes => (totalDurationSeconds / 60).round();

  /// ⏱ Tổng giờ đọc
  double get totalHours => totalDurationSeconds / 3600;

  /// 📊 Dữ liệu chart (seconds theo từng ngày/tuần/tháng)
  List<int> get chartTimes => items.map((e) => e.totalDurationSeconds).toList();

  /// 🏷 Label cho chart (date)
  List<String> get chartLabels =>
      items.map((e) => DateFormat('dd/MM').format(e.date)).toList();
}
