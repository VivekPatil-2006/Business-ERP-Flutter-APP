import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../services/dashboard_service.dart';
import '../widgets/analytics_card.dart';
import '../widgets/kpi_card.dart';
import '../charts/enquiry_chart.dart';

class EnquiryAnalyticsSection extends StatelessWidget {
  const EnquiryAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AnalyticsCard(
      title: 'Enquiry Analytics',
      child: FutureBuilder<Map<String, int>>(
        future: DashboardService().enquiryStats(),
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
          final pending = data['pending'] ?? 0;
          final answered = data['answered'] ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔢 KPI CARDS (NO OVERFLOW)
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  KpiCard(
                    title: 'Total',
                    value: total.toString(),
                  ),
                  KpiCard(
                    title: 'Pending',
                    value: pending.toString(),
                  ),
                  KpiCard(
                    title: 'Answered',
                    value: answered.toString(),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 📊 BAR CHART
              EnquiryChart(
                total: total,
                pending: pending,
                answered: answered,
              ),
            ],
          );
        },
      ),
    );
  }
}
