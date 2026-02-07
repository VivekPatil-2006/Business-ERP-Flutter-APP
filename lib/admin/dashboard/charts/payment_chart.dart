import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PaymentChart extends StatelessWidget {
  final double received;
  final double pending;

  const PaymentChart({
    super.key,
    required this.received,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: received,
              title: 'Received',
              color: Colors.green,
              radius: 60,
            ),
            PieChartSectionData(
              value: pending,
              title: 'Pending',
              color: Colors.orange,
              radius: 60,
            ),
          ],
        ),
      ),
    );
  }
}
