// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../core/theme/app_colors.dart';
//
// class QuotationDetailsScreen extends StatelessWidget {
//
//   final String quotationId;
//   final String clientId;
//   final String productId;
//
//   const QuotationDetailsScreen({
//     super.key,
//     required this.quotationId,
//     required this.clientId,
//     required this.productId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text(
//           "Quotation Details",
//           style: TextStyle(
//             fontWeight: FontWeight.bold, // ✅ bold title
//           ),
//         ),
//         backgroundColor: AppColors.darkBlue,
//         foregroundColor: Colors.white, // ✅ affects title + back arrow
//       ),
//
//
//       body: FutureBuilder<DocumentSnapshot>(
//
//         future: FirebaseFirestore.instance
//             .collection("quotations")
//             .doc(quotationId)
//             .get(),
//
//         builder: (context, snapshot) {
//
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.data!.exists) {
//             return const Center(child: Text("Quotation not found"));
//           }
//
//           final data =
//           snapshot.data!.data() as Map<String, dynamic>;
//
//           final productSnapshot =
//               data['productSnapshot'] ?? {};
//
//           final status =
//               data['status'] ?? "sent";
//
//           final amount =
//               data['quotationAmount'] ?? 0;
//
//           return SingleChildScrollView(
//
//             padding: const EdgeInsets.all(16),
//
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 section("Quotation Info"),
//
//                 info("Quotation ID", quotationId),
//                 info("Status", status.toUpperCase()),
//                 info("Final Amount", "₹ $amount"),
//
//                 const Divider(height: 30),
//
//                 section("Product Info"),
//
//                 info("Product Name",
//                     productSnapshot['productName']),
//
//                 info("Quantity",
//                     productSnapshot['quantity']),
//
//                 info("Base Price",
//                     productSnapshot['basePrice']),
//
//                 info("Discount %",
//                     productSnapshot['discountPercent']),
//
//                 info("Extra Discount %",
//                     productSnapshot['extraDiscountPercent']),
//
//                 info("CGST %",
//                     productSnapshot['cgstPercent']),
//
//                 info("SGST %",
//                     productSnapshot['sgstPercent']),
//
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ================= UI HELPERS =================
//
//   Widget section(String title) {
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.blue,
//         ),
//       ),
//     );
//   }
//
//   Widget info(String label, dynamic value) {
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//
//       child: Row(
//         children: [
//
//           SizedBox(
//             width: 140,
//             child: Text(
//               "$label:",
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//
//           Expanded(
//             child: Text(
//               value?.toString() ?? "-",
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import 'services/quotation_service.dart';

class QuotationDetailsScreen extends StatefulWidget {
  final String quotationId;

  const QuotationDetailsScreen({
    super.key,
    required this.quotationId,
  });

  @override
  State<QuotationDetailsScreen> createState() =>
      _QuotationDetailsScreenState();
}

class _QuotationDetailsScreenState
    extends State<QuotationDetailsScreen> {
  bool loading = true;
  Map<String, dynamic>? quotation;

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  // =============================
  // LOAD QUOTATION DETAILS
  // =============================

  Future<void> loadDetails() async {
    try {
      quotation = await QuotationService()
          .getQuotationById(widget.quotationId);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pricing =
    quotation?['pricing'] as Map<String, dynamic>?;

    final createdAt = quotation?['createdAt'] != null
        ? DateTime.tryParse(quotation!['createdAt'])
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quotation Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : quotation == null
          ? const Center(child: Text("Quotation not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            section("Quotation Info"),

            info("Quotation ID",
                quotation!['quotationId']),
            info("Status",
                quotation!['status']?.toUpperCase()),

            if (createdAt != null)
              info(
                "Created At",
                DateFormat.yMMMd()
                    .add_jm()
                    .format(createdAt),
              ),

            const Divider(height: 32),

            section("Pricing Details"),

            info("Base Amount",
                "₹ ${pricing?['baseAmount']}"),
            info("Quantity",
                pricing?['quantity']?.toString()),
            info(
              "Discount %",
              "${pricing?['discountPercent']} %",
            ),
            info(
              "Extra Discount",
              "₹ ${pricing?['extraDiscount']}",
            ),
            info(
              "CGST %",
              "${pricing?['cgstPercent']} %",
            ),
            info(
              "SGST %",
              "${pricing?['sgstPercent']} %",
            ),

            const Divider(height: 24),

            info(
              "Final Amount",
              "₹ ${pricing?['totalAmount']}",
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }

  Widget info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
