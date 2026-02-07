// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../core/theme/app_colors.dart';
// import '../loi/client_loi_upload_screen.dart';
// import '../payments/client_payment_screen.dart';
//
// class ClientQuotationDetailsScreen extends StatefulWidget {
//
//   final String quotationId;
//
//   const ClientQuotationDetailsScreen({
//     super.key,
//     required this.quotationId,
//   });
//
//   @override
//   State<ClientQuotationDetailsScreen> createState() =>
//       _ClientQuotationDetailsScreenState();
// }
//
// class _ClientQuotationDetailsScreenState
//     extends State<ClientQuotationDetailsScreen> {
//
//   // =========================
//   // STEP INDEX
//   // =========================
//
//   int getStepIndex(String status) {
//
//     if (status == "payment_done") return 2;
//     if (status == "loi_sent") return 1;
//     return 0;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text("Quotation Details"),
//         backgroundColor: AppColors.darkBlue,
//       ),
//
//       // ✅ REALTIME STREAM
//       body: StreamBuilder<DocumentSnapshot>(
//
//         stream: FirebaseFirestore.instance
//             .collection("quotations")
//             .doc(widget.quotationId)
//             .snapshots(),
//
//         builder: (context, snapshot) {
//
//           // ---------------- LOADING ----------------
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           // ---------------- ERROR ----------------
//
//           if (snapshot.hasError) {
//             return const Center(child: Text("Failed to load quotation"));
//           }
//
//           // ---------------- EMPTY ----------------
//
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text("Quotation not found"));
//           }
//
//           final data =
//           snapshot.data!.data() as Map<String, dynamic>;
//
//           final product =
//               data['productSnapshot'] ?? {};
//
//           final status =
//               data['status'] ?? "sent";
//
//           final currentStep =
//           getStepIndex(status);
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 // ================= TIMELINE =================
//
//                 buildTimeline(currentStep),
//
//                 const SizedBox(height: 20),
//
//                 // ================= DETAILS =================
//
//                 buildRow(
//                   "Product",
//                   product['productName'] ?? "-",
//                 ),
//
//                 buildRow(
//                   "Final Amount",
//                   "₹ ${data['quotationAmount'] ?? 0}",
//                 ),
//
//                 const Divider(height: 30),
//
//                 buildRow(
//                   "Status",
//                   status.toUpperCase(),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // ================= UPLOAD LOI =================
//
//                 if (status != "loi_sent" &&
//                     status != "payment_done")
//
//                   SizedBox(
//                     width: double.infinity,
//
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.darkBlue,
//                       ),
//
//                       child: const Text(
//                         "UPLOAD LOI",
//                         style: TextStyle(color: Colors.white),
//                       ),
//
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 ClientLoiUploadScreen(
//                                   quotationId:
//                                   widget.quotationId,
//                                 ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//
//                 // ================= PAYMENT =================
//
//                 if (status == "loi_sent")
//
//                   SizedBox(
//                     width: double.infinity,
//
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                       ),
//
//                       onPressed: () {
//
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                             const ClientPaymentScreen(),
//                           ),
//                         );
//                       },
//
//                       child: const Text(
//                         "MAKE PAYMENT",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//
//                 // ================= COMPLETED =================
//
//                 if (status == "payment_done")
//
//                   const Center(
//                     child: Padding(
//                       padding: EdgeInsets.only(top: 16),
//                       child: Text(
//                         "Payment Completed ✅",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ================= TIMELINE =================
//
//   Widget buildTimeline(int currentStep) {
//
//     final steps = [
//       "Quotation",
//       "LOI",
//       "Payment",
//     ];
//
//     return Row(
//       children: List.generate(
//         steps.length * 2 - 1,
//             (index) {
//
//           // ---------- CONNECTOR ----------
//           if (index.isOdd) {
//
//             final stepIndex = index ~/ 2;
//
//             final isActive =
//                 stepIndex < currentStep;
//
//             return Expanded(
//               child: Container(
//                 height: 3,
//                 color: isActive
//                     ? Colors.green
//                     : Colors.grey.shade300,
//               ),
//             );
//           }
//
//           // ---------- STEP ----------
//           final step = index ~/ 2;
//
//           final isCompleted =
//               step < currentStep;
//
//           final isCurrent =
//               step == currentStep;
//
//           Color circleColor = Colors.grey;
//
//           if (isCompleted) {
//             circleColor = Colors.green;
//           }
//
//           if (isCurrent) {
//             circleColor = AppColors.primaryBlue;
//           }
//
//           return Column(
//             children: [
//
//               Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: circleColor,
//                   shape: BoxShape.circle,
//                 ),
//
//                 child: Center(
//                   child: Icon(
//                     isCompleted
//                         ? Icons.check
//                         : Icons.circle,
//                     size: 14,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 6),
//
//               SizedBox(
//                 width: 70,
//
//                 child: Text(
//                   steps[step],
//                   textAlign: TextAlign.center,
//
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: isCurrent
//                         ? FontWeight.bold
//                         : FontWeight.normal,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   // ================= ROW UI =================
//
//   Widget buildRow(String title, String value) {
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//
//       child: Row(
//         children: [
//
//           SizedBox(
//             width: 120,
//
//             child: Text(
//               "$title:",
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
// }
