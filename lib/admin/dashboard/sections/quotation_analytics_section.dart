// import 'package:flutter/material.dart';
//
// import '../../../core/theme/app_colors.dart';
// import '../services/dashboard_service.dart';
// import '../widgets/analytics_card.dart';
// import '../widgets/kpi_card.dart';
// import '../charts/quotation_chart.dart';
//
// class QuotationAnalyticsSection extends StatelessWidget {
//   const QuotationAnalyticsSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnalyticsCard(
//       title: 'Quotation Analytics',
//       child: FutureBuilder<Map<String, int>>(
//         future: DashboardService().quotationStats(),
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
//           final loiSent = data['loi_sent'] ?? 0;
//           final paymentDone = data['payment_done'] ?? 0;
//
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   children: [
//                     KpiCard(
//                       title: 'Total Quotations',
//                       value: total.toString(),
//                     ),
//                     KpiCard(
//                       title: 'LOI Sent',
//                       value: loiSent.toString(),
//                     ),
//                     KpiCard(
//                       title: 'Payment Done',
//                       value: paymentDone.toString(),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 28),
//
//                 QuotationChart(
//                   total: total,
//                   loiSent: loiSent,
//                   paymentDone: paymentDone,
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//
//   }
// }
