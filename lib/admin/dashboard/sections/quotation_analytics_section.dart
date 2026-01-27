import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/dashboard_service.dart';
import '../widgets/analytics_card.dart';
import '../widgets/kpi_card.dart';
import '../charts/quotation_chart.dart';

class QuotationAnalyticsSection extends StatelessWidget {
  const QuotationAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AnalyticsCard(
      title: 'Quotation Analytics',
      child: FutureBuilder<Map<String, int>>(
        future: DashboardService().quotationStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final total = data['total'] ?? 0;
          final accepted = data['accepted'] ?? 0;
          final declined = data['declined'] ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔢 KPI CARDS
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  KpiCard(title: 'Total', value: total.toString()),
                  KpiCard(title: 'Accepted', value: accepted.toString()),
                  KpiCard(title: 'Declined', value: declined.toString()),
                ],
              ),

              const SizedBox(height: 28),

              // 📊 QUOTATION PIE CHART (FIXED)
              QuotationChart(
                accepted: accepted,
                declined: declined,
              ),
            ],
          );
        },
      ),
    );
  }
}
