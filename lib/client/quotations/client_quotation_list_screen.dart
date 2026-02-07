// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../core/theme/app_colors.dart';
// import 'client_quotation_details_screen.dart';
//
// class ClientQuotationListScreen extends StatefulWidget {
//   const ClientQuotationListScreen({super.key});
//
//   @override
//   State<ClientQuotationListScreen> createState() =>
//       _ClientQuotationListScreenState();
// }
//
// class _ClientQuotationListScreenState
//     extends State<ClientQuotationListScreen> {
//
//   String companyId = "";
//   bool loading = true;
//
//   Color getStatusColor(String status) {
//     switch (status) {
//       case "loi_sent":
//         return Colors.orange;
//       case "payment_done":
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     loadClientCompany();
//   }
//
//   Future<void> loadClientCompany() async {
//
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//
//     final snap = await FirebaseFirestore.instance
//         .collection("clients")
//         .doc(uid)
//         .get();
//
//     companyId = snap.data()?['companyId'] ?? "";
//
//     if (mounted) {
//       setState(() => loading = false);
//     }
//   }
//
//   Stream<QuerySnapshot> fetchMyQuotations() {
//
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//
//     return FirebaseFirestore.instance
//         .collection("quotations")
//         .where("clientId", isEqualTo: uid)
//         .where("companyId", isEqualTo: companyId)
//         .orderBy("createdAt", descending: true)
//         .snapshots();
//   }
//
//   // ================= STATUS CHIP =================
//
//   Widget statusChip(String status) {
//
//     final color = getStatusColor(status);
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: color,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//
//       appBar: AppBar(
//         backgroundColor: AppColors.darkBlue,
//         elevation: 0,
//
//         // 👈 back arrow color
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//
//         // 👈 title text color
//         title: const Text(
//           "My Quotations",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//
//       body: StreamBuilder<QuerySnapshot>(
//         stream: fetchMyQuotations(),
//
//         builder: (context, snapshot) {
//
//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return const Center(
//                 child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData ||
//               snapshot.data!.docs.isEmpty) {
//             return const Center(
//                 child: Text("No quotations yet"));
//           }
//
//           final quotes = snapshot.data!.docs;
//
//           return ListView.builder(
//
//             padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//
//             itemCount: quotes.length,
//
//             itemBuilder: (context, index) {
//
//               final q = quotes[index];
//               final data = q.data() as Map<String, dynamic>;
//
//               final amount =
//               (data['quotationAmount'] ?? 0).toDouble();
//
//               final status = data['status'] ?? "";
//
//               return GestureDetector(
//
//                 onTap: () {
//
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                           ClientQuotationDetailsScreen(
//                             quotationId: q.id,
//                           ),
//                     ),
//                   );
//                 },
//
//                 child: Container(
//
//                   margin: const EdgeInsets.only(bottom: 12),
//
//                   padding: const EdgeInsets.all(14),
//
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: [
//                       BoxShadow(
//                         blurRadius: 6,
//                         color:
//                         Colors.black.withOpacity(0.05),
//                       ),
//                     ],
//                   ),
//
//                   child: Row(
//                     crossAxisAlignment:
//                     CrossAxisAlignment.center,
//
//                     children: [
//
//                       // ================= ICON =================
//
//                       CircleAvatar(
//                         radius: 22,
//
//                         backgroundColor:
//                         getStatusColor(status)
//                             .withOpacity(0.15),
//
//                         child: Icon(
//                           Icons.description,
//                           color: getStatusColor(status),
//                         ),
//                       ),
//
//                       const SizedBox(width: 12),
//
//                       // ================= CONTENT =================
//
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment:
//                           CrossAxisAlignment.start,
//
//                           children: [
//
//                             Text(
//                               "₹ ${amount.toStringAsFixed(2)}",
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight:
//                                 FontWeight.bold,
//                               ),
//                             ),
//
//                             const SizedBox(height: 4),
//
//                             Text(
//                               "Quotation Amount",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // ================= STATUS =================
//
//                       statusChip(status),
//
//                       const SizedBox(width: 8),
//
//                       const Icon(
//                         Icons.arrow_forward_ios,
//                         size: 16,
//                         color: Colors.grey,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
