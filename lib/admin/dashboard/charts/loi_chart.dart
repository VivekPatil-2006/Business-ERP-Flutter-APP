import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoiChart extends StatelessWidget {
  final int total;
  final int accepted;
  final int rejected;
  final int pending;

  const LoiChart({
    super.key,
    required this.total,
    required this.accepted,
    required this.rejected,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      total,
      accepted,
      rejected,
      pending,
    ].reduce((a, b) => a > b ? a : b);

    if (maxValue == 0) {
      return const Center(
        child: Text(
          'No LOI data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.32,
      child: BarChart(
        BarChartData(
          maxY: (maxValue + 2).toDouble(),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return _bottomTitle('Total');
                    case 1:
                      return _bottomTitle('Accepted');
                    case 2:
                      return _bottomTitle('Rejected');
                    case 3:
                      return _bottomTitle('Pending');
                    default:
                      return const SizedBox.shrink();
                  }
                },

              ),
            ),
          ),
          barGroups: [
            _bar(0, total, AppColors.primaryBlue),
            _bar(1, accepted, Colors.green),
            _bar(2, rejected, Colors.redAccent),
            _bar(3, pending, Colors.orange),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, int y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          width: 24,
          borderRadius: BorderRadius.circular(6),
          color: color,
        ),
      ],
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

