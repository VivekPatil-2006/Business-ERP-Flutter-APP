// import 'package:flutter/material.dart';
//
// import '../services/dashboard_service.dart';
// import '../widgets/analytics_card.dart';
// import '../widgets/alert_card.dart';
// import '../charts/client_funnel_chart.dart';
//
// class ClientMovementSection extends StatelessWidget {
//   const ClientMovementSection({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnalyticsCard(
//       title: 'Client Movement Monitoring',
//       child: FutureBuilder<int>(
//         future: DashboardService().stalledClients(),
//         builder: (context, snapshot) {
//           final stalled = snapshot.data ?? 0;
//
//           return Column(
//             children: [
//               AlertCard(
//                 message: stalled == 0
//                     ? 'No stalled clients 🎉'
//                     : '$stalled client(s) waiting without response',
//                 color: stalled == 0
//                     ? Colors.green.shade100
//                     : Colors.red.shade100,
//               ),
//               const SizedBox(height: 20),
//               const ClientFunnelChart(),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
