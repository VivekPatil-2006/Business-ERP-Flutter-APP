// import 'package:flutter/material.dart';
//
// import '../../../core/theme/app_colors.dart';
// import '../services/dashboard_service.dart';
// import '../widgets/analytics_card.dart';
// import '../widgets/kpi_card.dart';
// import '../charts/loi_chart.dart';
//
// class LoiAnalyticsSection extends StatelessWidget {
//   const LoiAnalyticsSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnalyticsCard(
//       title: 'LOI Analytics',
//       child: FutureBuilder<Map<String, int>>(
//         future: DashboardService().loiStats(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Padding(
//               padding: EdgeInsets.all(24),
//               child: Center(
//                 child: CircularProgressIndicator(
//                   color: AppColors.primaryBlue,
//                 ),
//               ),
//             );
//           }
//
//           final data = snapshot.data!;
//
//           final total = data['total'] ?? 0;
//           final accepted = data['accepted'] ?? 0;
//           final rejected = data['rejected'] ?? 0;
//           final pending = data['pending'] ?? 0;
//
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔢 KPI CARDS
//               Wrap(
//                 spacing: 16,
//                 runSpacing: 16,
//                 children: [
//                   KpiCard(
//                     title: 'Total LOIs',
//                     value: total.toString(),
//                   ),
//                   KpiCard(
//                     title: 'Accepted',
//                     value: accepted.toString(),
//                   ),
//                   KpiCard(
//                     title: 'Rejected',
//                     value: rejected.toString(),
//                   ),
//                   KpiCard(
//                     title: 'Pending',
//                     value: pending.toString(),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 28),
//
//               // 📊 LOI BAR CHART
//               LoiChart(
//                 total: total,
//                 accepted: accepted,
//                 rejected: rejected,
//                 pending: pending,
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
