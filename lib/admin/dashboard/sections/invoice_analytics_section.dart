import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/analytics_card.dart';
import '../widgets/empty_chart_placeholder.dart';

class InvoiceAnalyticsSection extends StatelessWidget {
  const InvoiceAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnalyticsCard(
      title: 'Invoice Analytics',
      child: EmptyChartPlaceholder(
        message: 'Invoice analytics will appear once invoices are generated.',
      ),
    );
  }
}
