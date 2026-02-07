import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EnquiryChart extends StatelessWidget {
  final int total;
  final int raised;
  final int quoted;

  const EnquiryChart({
    super.key,
    required this.total,
    required this.raised,
    required this.quoted,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [total, raised, quoted]
        .reduce((a, b) => a > b ? a : b);

    // ✅ Add headroom so bars don’t touch top
    final double maxY =
    (maxValue == 0) ? 5 : (maxValue * 1.3).ceilToDouble();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.32,
      child: BarChart(
        BarChartData(
          maxY: maxY,

          // ================= TOUCH =================
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.navy,
              getTooltipItem: (group, _, rod, __) {
                return BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),

          // ================= GRID =================
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),

          borderData: FlBorderData(show: false),

          // ================= AXES =================
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 5,
                reservedSize: 36,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 0:
                      return _bottomTitle('Total');
                    case 1:
                      return _bottomTitle('Unanswered');
                    case 2:
                      return _bottomTitle('Answered');
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),

          // ================= BARS =================
          barGroups: [
            _bar(0, total, AppColors.primaryBlue),
            _bar(1, raised, Colors.orange),
            _bar(2, quoted, Colors.green),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  BarChartGroupData _bar(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barsSpace: 6,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          width: 26,
          color: color,
          borderRadius: BorderRadius.circular(8),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 0,
            color: color.withOpacity(0.12),
          ),
        ),
      ],
    );
  }

  Widget _bottomLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.navy,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
Widget _bottomTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,        // 👈 reduced size
        fontWeight: FontWeight.bold,
        color: Colors.grey, // optional
      ),
    ),
  );
}