// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// import '../../core/theme/app_colors.dart';
//
// class ClientEnquiryDetailsScreen extends StatelessWidget {
//
//   final String enquiryId;
//
//   const ClientEnquiryDetailsScreen({
//     super.key,
//     required this.enquiryId,
//   });
//
//   // ======================
//   // STATUS COLOR
//   // ======================
//
//   Color getStatusColor(String status) {
//     switch (status) {
//       case "raised":
//         return Colors.orange;
//       case "quoted":
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Enquiry Details"),
//         backgroundColor: AppColors.darkBlue,
//       ),
//
//       body: FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection("enquiries")
//             .doc(enquiryId)
//             .get(),
//
//         builder: (context, snapshot) {
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text("Enquiry not found"));
//           }
//
//           final data =
//           snapshot.data!.data() as Map<String, dynamic>;
//
//           final status = data['status'] ?? "raised";
//
//           final createdAt = data['createdAt'] != null
//               ? (data['createdAt'] as Timestamp).toDate()
//               : DateTime.now();
//
//           final productId = data['productId'];
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 // ================= STATUS =================
//
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 14, vertical: 6),
//
//                   decoration: BoxDecoration(
//                     color: getStatusColor(status).withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//
//                   child: Text(
//                     status.toUpperCase(),
//                     style: TextStyle(
//                       color: getStatusColor(status),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 18),
//
//                 // ================= ENQUIRY =================
//
//                 buildSection("Enquiry Information", [
//
//                   infoRow("Title", data['title']),
//                   infoRow("Description", data['description']),
//                   infoRow("Quantity", data['quantity']?.toString()),
//
//                   infoRow(
//                     "Created On",
//                     DateFormat.yMMMd().format(createdAt),
//                   ),
//
//                   infoRow("Source", data['source'] ?? "-"),
//                 ]),
//
//                 // ================= PRODUCT =================
//
//                 if (productId != null)
//
//                   FutureBuilder<DocumentSnapshot>(
//                     future: FirebaseFirestore.instance
//                         .collection("products")
//                         .doc(productId)
//                         .get(),
//
//                     builder: (context, productSnap) {
//
//                       if (!productSnap.hasData ||
//                           !productSnap.data!.exists) {
//
//                         return buildSection("Product Details", [
//                           infoRow("Product", "Not Available"),
//                         ]);
//                       }
//
//                       final product =
//                       productSnap.data!.data() as Map<String, dynamic>;
//
//                       final pricing = product['pricing'] ?? {};
//
//                       return buildSection("Product Details", [
//
//                         infoRow("Name", product['title']),
//                         infoRow(
//                           "Base Price",
//                           "₹ ${pricing['basePrice'] ?? 0}",
//                         ),
//                       ]);
//                     },
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ======================
//   // UI HELPERS
//   // ======================
//
//   Widget buildSection(String title, List<Widget> children) {
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(14),
//
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//           ),
//         ],
//       ),
//
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Text(
//             title,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16),
//           ),
//
//           const Divider(),
//
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   Widget infoRow(String label, dynamic value) {
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           SizedBox(
//             width: 130,
//             child: Text(
//               "$label:",
//               style: const TextStyle(
//                   fontWeight: FontWeight.w600),
//             ),
//           ),
//
//           Expanded(
//             child: Text(
//               value == null || value.toString().isEmpty
//                   ? "-"
//                   : value.toString(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
