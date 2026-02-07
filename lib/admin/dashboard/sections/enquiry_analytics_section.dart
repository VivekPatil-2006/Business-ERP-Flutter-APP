// import 'package:flutter/material.dart';
//
// import '../../../core/theme/app_colors.dart';
// import '../services/dashboard_service.dart';
// import '../widgets/analytics_card.dart';
// import '../widgets/kpi_card.dart';
// import '../charts/enquiry_chart.dart';
//
// class EnquiryAnalyticsSection extends StatelessWidget {
//   const EnquiryAnalyticsSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnalyticsCard(
//       title: 'Enquiry Analytics',
//       child: FutureBuilder<Map<String, int>>(
//         future: DashboardService().enquiryStats(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Padding(
//               padding: EdgeInsets.all(22),
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
//           // ✅ FINAL STATUS MAPPING
//           final total = data['total'] ?? 0;
//           final raised = data['raised'] ?? 0;
//           final quoted = data['quoted'] ?? 0;
//
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔢 KPI CARDS
//               Wrap(
//                 spacing: 15,
//                 runSpacing: 15,
//                 children: [
//                   KpiCard(
//                     title: 'Total Enquiries',
//                     value: total.toString(),
//                   ),
//                   KpiCard(
//                     title: 'Unanswered',
//                     value: raised.toString(),
//                   ),
//                   KpiCard(
//                     title: 'Answered',
//                     value: quoted.toString(),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 28),
//
//               // 📊 BAR CHART (CORRECT PARAMS)
//               EnquiryChart(
//                 total: total,
//                 raised: raised,
//                 quoted: quoted,
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
