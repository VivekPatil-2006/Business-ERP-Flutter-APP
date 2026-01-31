import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ClientFunnelChart extends StatelessWidget {
  const ClientFunnelChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barGroups: [
            _bar(0, 10), // enquiries
            _bar(1, 6),  // quoted
            _bar(2, 3),  // loi
            _bar(3, 1),  // paid
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, int y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          width: 20,
          color: Colors.blue,
        ),
      ],
    );
  }
}
