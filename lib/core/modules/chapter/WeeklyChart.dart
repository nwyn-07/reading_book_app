import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:reading_book_app/core/theme/AppColors.dart';

class WeeklyHourChart extends StatelessWidget {
  final List<double> data;

  const WeeklyHourChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = data.every((e) => e == 0);
    if (isEmpty) {
      return _buildEmptyState();
    }

    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxY = _getMaxY(data);
    final interval = _getHorizontalInterval(maxY);
    final todayIndex = DateTime.now().weekday - 1; // Mon = 0

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceBetween,

        // ================= TOUCH =================
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
                '${rod.toY.toStringAsFixed(1)} giờ',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),

        // ================= AXIS =================
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

        // ================= GRID =================
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.white10, strokeWidth: 0.6),
        ),

        borderData: FlBorderData(show: false),

        // ================= BARS =================
        barGroups: List.generate(data.length, (i) {
          final isToday = i == todayIndex;
          final value = data[i];

          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value,
                width: 16,
                borderRadius: BorderRadius.circular(6),

                // 🎯 MÀU ĐƠN, KHÔNG GRADIENT
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

      // 🎬 ANIMATION
      swapAnimationDuration: const Duration(milliseconds: 900),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }

  // ================= EMPTY STATE =================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bar_chart, size: 64, color: Colors.white24),
          SizedBox(height: 12),
          Text(
            'Chưa có dữ liệu tuần này',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            'Hãy nghe truyện để xem thống kê 📊',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
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
