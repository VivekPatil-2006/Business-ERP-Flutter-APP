// import 'package:flutter/material.dart';
//
// import '../../../core/theme/app_colors.dart';
// import '../services/dashboard_service.dart';
// import '../widgets/analytics_card.dart';
// import '../widgets/kpi_card.dart';
// import '../charts/payment_chart.dart';
//
// class PaymentAnalyticsSection extends StatelessWidget {
//   const PaymentAnalyticsSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnalyticsCard(
//       title: 'Payment Analytics',
//       child: FutureBuilder<Map<String, double>>(
//         future: DashboardService().paymentStats(),
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
//           final received = data['received'] ?? 0;
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
//                     title: 'Received',
//                     value: '₹ ${received.toStringAsFixed(0)}',
//                   ),
//                   KpiCard(
//                     title: 'Pending',
//                     value: '₹ ${pending.toStringAsFixed(0)}',
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 28),
//
//               // 📊 PAYMENT PIE CHART (FIXED)
//               PaymentChart(
//                 received: received,
//                 pending: pending,
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
