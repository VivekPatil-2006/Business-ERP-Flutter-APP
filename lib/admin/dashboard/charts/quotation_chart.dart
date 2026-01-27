import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuotationChart extends StatelessWidget {
  final int accepted;
  final int declined;

  const QuotationChart({
    super.key,
    required this.accepted,
    required this.declined,
  });

  @override
  Widget build(BuildContext context) {
    final total = accepted + declined;

    if (total == 0) {
      return const Center(
        child: Text(
          'No quotation data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sectionsSpace: 4,
          sections: [
            PieChartSectionData(
              value: accepted.toDouble(),
              color: Colors.green,
              title: 'Accepted\n$accepted',
              radius: 60,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            PieChartSectionData(
              value: declined.toDouble(),
              color: Colors.red,
              title: 'Declined\n$declined',
              radius: 60,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
