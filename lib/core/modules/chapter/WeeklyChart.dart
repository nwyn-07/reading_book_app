import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';
import 'package:reading_book_app/core/models/ReadingStatsItem.dart';

class WeeklyHourChart extends StatelessWidget {
  final List<ReadingStatsItem> items;

  const WeeklyHourChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final data = _buildWeeklyHours(items);
    final bool isEmpty = data.every((e) => e == 0);
    if (isEmpty) {
      return _buildEmptyState();
    }

    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIndex = DateTime.now().weekday - 1;

    final maxY = _getMaxY(data);
    final interval = _getHorizontalInterval(maxY);

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceBetween,

        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            getTooltipItem: (group, _, rod, __) {
              return BarTooltipItem(
                '${weekDays[group.x.toInt()]}\n'
                '${rod.toY.toStringAsFixed(1)} phút',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),

        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: interval,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                final isToday = index == todayIndex;

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    weekDays[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? Colors.lightBlueAccent : Colors.white70,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.white10, strokeWidth: 0.6),
        ),

        borderData: FlBorderData(show: false),

        barGroups: List.generate(7, (i) {
          final isToday = i == todayIndex;
          final value = data[i];

          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value,
                width: 16,
                borderRadius: BorderRadius.circular(6),
                color: isToday ? AppColors.accent : AppColors.playButtonIcon,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: Colors.white10,
                ),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 900),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }

  List<double> _buildWeeklyHours(List<ReadingStatsItem> items) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    final Map<int, double> map = {};

    for (final item in items) {
      final itemDate = DateTime(item.date.year, item.date.month, item.date.day);

      final index = itemDate.difference(startOfWeek).inDays;

      if (index >= 0 && index < 7) {
        map[index] = item.totalDurationSeconds / 60;
      }
    }

    return List.generate(7, (i) => map[i] ?? 0.0);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.white24),
          SizedBox(height: 12),
          Text(
            'Chưa có dữ liệu tuần này',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  double _getMaxY(List<double> data) {
    final max = data.reduce((a, b) => a > b ? a : b);
    if (max < 1) return 1;
    return (max * 1.25).ceilToDouble();
  }

  double _getHorizontalInterval(double maxY) {
    if (maxY <= 2) return 0.5;
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    return 10;
  }
}
