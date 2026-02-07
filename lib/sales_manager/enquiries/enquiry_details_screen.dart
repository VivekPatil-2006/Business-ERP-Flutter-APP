// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:intl/intl.dart';
// //
// // import '../../core/theme/app_colors.dart';
// // import 'create_enquiry_screen.dart';
// //
// // class EnquiryDetailsScreen extends StatefulWidget {
// //   final String enquiryId;
// //
// //   const EnquiryDetailsScreen({
// //     super.key,
// //     required this.enquiryId,
// //   });
// //
// //   @override
// //   State<EnquiryDetailsScreen> createState() =>
// //       _EnquiryDetailsScreenState();
// // }
// //
// // class _EnquiryDetailsScreenState extends State<EnquiryDetailsScreen> {
// //   final firestore = FirebaseFirestore.instance;
// //
// //   bool loading = true;
// //
// //   Map<String, dynamic>? enquiry;
// //   Map<String, dynamic>? client;
// //   Map<String, dynamic>? product;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadDetails();
// //   }
// //
// //   // ===============================
// //   // LOAD ALL DETAILS
// //   // ===============================
// //
// //   Future<void> loadDetails() async {
// //     try {
// //       // -------- ENQUIRY --------
// //       final enquirySnap = await firestore
// //           .collection("enquiries")
// //           .doc(widget.enquiryId)
// //           .get();
// //
// //       if (!enquirySnap.exists) {
// //         return;
// //       }
// //
// //       enquiry = enquirySnap.data();
// //
// //       // -------- CLIENT --------
// //       if (enquiry!['clientId'] != null) {
// //         final clientSnap = await firestore
// //             .collection("clients")
// //             .doc(enquiry!['clientId'])
// //             .get();
// //
// //         if (clientSnap.exists) {
// //           client = clientSnap.data();
// //         }
// //       }
// //
// //       // -------- PRODUCT --------
// //       if (enquiry!['productId'] != null) {
// //         final productSnap = await firestore
// //             .collection("products")
// //             .doc(enquiry!['productId'])
// //             .get();
// //
// //         if (productSnap.exists) {
// //           product = productSnap.data();
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint("Enquiry Details Error => $e");
// //     } finally {
// //       if (mounted) {
// //         setState(() => loading = false);
// //       }
// //     }
// //   }
// //
// //   // ===============================
// //   // UI
// //   // ===============================
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text(
// //           "Enquiry Details",
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold, // 👈 add weight
// //           ),
// //         ),
// //         backgroundColor: AppColors.darkBlue,
// //         foregroundColor: Colors.white,
// //
// //       ),
// //       body: loading
// //           ? const Center(child: CircularProgressIndicator())
// //           : enquiry == null
// //           ? const Center(child: Text("Enquiry not found"))
// //           : SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             buildSection(
// //               title: "Enquiry Information",
// //               icon: Icons.assignment,
// //               child: buildEnquiryInfo(),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             buildSection(
// //               title: "Client Information",
// //               icon: Icons.people,
// //               child: buildClientInfo(),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             buildSection(
// //               title: "Product Information",
// //               icon: Icons.inventory,
// //               child: buildProductInfo(),
// //             ),
// //
// //             const SizedBox(height: 24),
// //
// //             buildActionButton(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ===============================
// //   // SECTIONS
// //   // ===============================
// //
// //   Widget buildEnquiryInfo() {
// //     final createdAt =
// //     (enquiry!['createdAt'] as Timestamp?)?.toDate();
// //     final expectedDate =
// //     (enquiry!['expectedDate'] as Timestamp?)?.toDate();
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         infoRow("Title", enquiry!['title']),
// //         infoRow("Description", enquiry!['description']),
// //         infoRow("Quantity", enquiry!['quantity'].toString()),
// //         infoRow("Source", enquiry!['source']),
// //         infoRow("Status", enquiry!['status']),
// //         if (createdAt != null)
// //           infoRow(
// //             "Created At",
// //             DateFormat.yMMMd().format(createdAt),
// //           ),
// //         if (expectedDate != null)
// //           infoRow(
// //             "Expected Date",
// //             DateFormat.yMMMd().format(expectedDate),
// //           ),
// //       ],
// //     );
// //   }
// //
// //   Widget buildClientInfo() {
// //     if (client == null) {
// //       return const Text("Client data not available");
// //     }
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         infoRow("Company", client!['companyName']),
// //         infoRow(
// //             "Contact Person", client!['contactPerson'] ?? "-"),
// //         infoRow("Email", client!['emailAddress'] ?? "-"),
// //         infoRow(
// //             "Phone", client!['phoneNo1'] ?? client!['cellphone'] ?? "-"),
// //         infoRow(
// //             "City",
// //             "${client!['city'] ?? '-'}, ${client!['state'] ?? '-'}"),
// //       ],
// //     );
// //   }
// //
// //   Widget buildProductInfo() {
// //     if (product == null) {
// //       return const Text("Product data not available");
// //     }
// //
// //     final pricing = product!['pricing'] ?? {};
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         infoRow("Product", product!['title']),
// //         infoRow("Item No", product!['itemNo'] ?? "-"),
// //         infoRow("Size", product!['size'] ?? "-"),
// //         infoRow(
// //             "Base Price",
// //             pricing['basePrice'] != null
// //                 ? "₹ ${pricing['basePrice']}"
// //                 : "-"),
// //         infoRow(
// //             "Total Price",
// //             pricing['totalPrice'] != null
// //                 ? "₹ ${pricing['totalPrice']}"
// //                 : "-"),
// //       ],
// //     );
// //   }
// //
// //   // ===============================
// //   // ACTION BUTTON
// //   // ===============================
// //
// //   Widget buildActionButton() {
// //     if (enquiry!['status'] == "quoted") {
// //       return const SizedBox.shrink();
// //     }
// //
// //     return SizedBox(
// //       width: double.infinity,
// //       child: ElevatedButton.icon(
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: AppColors.darkBlue,
// //           padding: const EdgeInsets.symmetric(vertical: 14),
// //         ),
// //         icon: const Icon(Icons.description, color: Colors.white),
// //         label: const Text(
// //           "CREATE QUOTATION",
// //           style: TextStyle(color: Colors.white),
// //         ),
// //         onPressed: () {
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (context) => const CreateEnquiryScreen(),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   // ===============================
// //   // HELPERS
// //   // ===============================
// //
// //   Widget buildSection({
// //     required String title,
// //     required IconData icon,
// //     required Widget child,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //         boxShadow: [
// //           BoxShadow(
// //             blurRadius: 6,
// //             color: Colors.black.withOpacity(0.05),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Icon(icon, color: AppColors.darkBlue),
// //               const SizedBox(width: 8),
// //               Text(
// //                 title,
// //                 style: const TextStyle(
// //                     fontWeight: FontWeight.bold),
// //               ),
// //             ],
// //           ),
// //           const Divider(),
// //           child,
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget infoRow(String label, String? value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 4),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //             width: 130,
// //             child: Text(
// //               "$label:",
// //               style:
// //               const TextStyle(fontWeight: FontWeight.w600),
// //             ),
// //           ),
// //           Expanded(
// //             child: Text(value ?? "-"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../../core/theme/app_colors.dart';
// import 'services/services.dart';
//
// class EnquiryDetailsScreen extends StatefulWidget {
//   final String enquiryId;
//
//   const EnquiryDetailsScreen({super.key, required this.enquiryId});
//
//   @override
//   State<EnquiryDetailsScreen> createState() =>
//       _EnquiryDetailsScreenState();
// }
//
// class _EnquiryDetailsScreenState extends State<EnquiryDetailsScreen> {
//   bool loading = true;
//   Map<String, dynamic>? enquiry;
//
//   @override
//   void initState() {
//     super.initState();
//     loadDetails();
//   }
//
//   Future<void> loadDetails() async {
//     try {
//       enquiry =
//       await EnquiryService().getEnquiryDetails(widget.enquiryId);
//     } finally {
//       setState(() => loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final createdAt = enquiry?['createdAt'] != null
//         ? DateTime.tryParse(enquiry!['createdAt'])
//         : null;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Enquiry Details"),
//         backgroundColor: AppColors.darkBlue,
//         foregroundColor: Colors.white,
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : enquiry == null
//           ? const Center(child: Text("Enquiry not found"))
//           : Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Title: ${enquiry!['title']}"),
//             Text("Status: ${enquiry!['status']}"),
//             Text("Source: ${enquiry!['source']}"),
//             if (createdAt != null)
//               Text(
//                 "Created: ${DateFormat.yMMMd().format(createdAt)}",
//               ),
//             const SizedBox(height: 12),
//             Text(enquiry!['description'] ?? "-"),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import 'services/services.dart';

class EnquiryDetailsScreen extends StatefulWidget {
  final String enquiryId;

  const EnquiryDetailsScreen({
    super.key,
    required this.enquiryId,
  });

  @override
  State<EnquiryDetailsScreen> createState() =>
      _EnquiryDetailsScreenState();
}

class _EnquiryDetailsScreenState extends State<EnquiryDetailsScreen> {
  bool loading = true;
  Map<String, dynamic>? enquiry;

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      enquiry =
      await EnquiryService().getEnquiryDetails(widget.enquiryId);
    } catch (e) {
      debugPrint("Enquiry Details Error => $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = enquiry?['createdAt'] != null
        ? DateTime.tryParse(enquiry!['createdAt'])
        : null;

    final expectedDate = enquiry?['expectedDate'] != null
        ? DateTime.tryParse(enquiry!['expectedDate'])
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enquiry Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : enquiry == null
          ? const Center(child: Text("Enquiry not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSection(
              title: "Enquiry Information",
              icon: Icons.assignment,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow("Title", enquiry!['title']),
                  infoRow(
                      "Description",
                      enquiry!['description']),
                  infoRow(
                      "Quantity",
                      enquiry!['quantity']?.toString()),
                  infoRow("Source", enquiry!['source']),
                  infoRow("Status", enquiry!['status']),
                  if (createdAt != null)
                    infoRow(
                      "Created At",
                      DateFormat.yMMMd().format(createdAt),
                    ),
                  if (expectedDate != null)
                    infoRow(
                      "Expected Date",
                      DateFormat.yMMMd()
                          .format(expectedDate),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.darkBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }

  Widget infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style:
              const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }
}
