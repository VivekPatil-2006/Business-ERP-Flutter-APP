// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../core/theme/app_colors.dart';
// import 'quotation_details_screen.dart';
// import 'create_quotation_screen.dart';
//
// class QuotationListSales extends StatefulWidget {
//   const QuotationListSales({super.key});
//
//   @override
//   State<QuotationListSales> createState() => _QuotationListSalesState();
// }
//
// class _QuotationListSalesState extends State<QuotationListSales> {
//
//   final _searchCtrl = TextEditingController();
//   String _searchText = '';
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     final salesManagerId = FirebaseAuth.instance.currentUser!.uid;
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text(
//           "My Quotations",
//           style: TextStyle(
//             fontWeight: FontWeight.bold, // ✅ bold title
//           ),
//         ),
//         backgroundColor: AppColors.darkBlue,
//         foregroundColor: Colors.white, // ✅ affects title + back arrow
//       ),
//
//
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.primaryBlue,
//         child: const Icon(Icons.add,color: Colors.white),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const CreateQuotationScreen()),
//           );
//         },
//       ),
//
//       body: Column(
//         children: [
//
//           // ================= SEARCH =================
//
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: TextField(
//               controller: _searchCtrl,
//               onChanged: (v) {
//                 setState(() => _searchText = v.toLowerCase());
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search quotation',
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(14),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),
//
//           // ================= LIST =================
//
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//
//               stream: FirebaseFirestore.instance
//                   .collection("quotations")
//                   .where("salesManagerId", isEqualTo: salesManagerId)
//                   .orderBy("createdAt", descending: true)
//                   .snapshots(),
//
//               builder: (context, snapshot) {
//
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text("No quotations found"));
//                 }
//
//                 final docs = snapshot.data!.docs;
//
//                 return ListView.builder(
//
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   itemCount: docs.length,
//
//                   itemBuilder: (context, index) {
//
//                     final doc = docs[index];
//                     final data = doc.data() as Map<String, dynamic>;
//
//                     final quotationId = doc.id;
//
//                     final clientId = data['clientId'];
//                     final status = data['status'] ?? "sent";
//
//                     final productSnapshot =
//                         data['productSnapshot'] ?? {};
//
//                     final productId =
//                     productSnapshot['productId'];
//
//                     final amount =
//                         data['quotationAmount'] ?? 0;
//
//                     // ---------- SEARCH FILTER ----------
//
//                     if (_searchText.isNotEmpty &&
//                         !quotationId.toLowerCase().contains(_searchText)) {
//                       return const SizedBox.shrink();
//                     }
//
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//
//                       child: ListTile(
//
//                         contentPadding: const EdgeInsets.all(16),
//
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => QuotationDetailsScreen(
//                                 quotationId: quotationId,
//                                 clientId: clientId,
//                                 productId: productId,
//                               ),
//                             ),
//                           );
//                         },
//
//                         title: Text(
//                           "Quotation #$quotationId",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//
//                         subtitle: Padding(
//                           padding: const EdgeInsets.only(top: 6),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//
//                               Text("Amount: ₹ $amount"),
//
//                               const SizedBox(height: 6),
//
//                               _statusChip(status),
//                             ],
//                           ),
//                         ),
//
//                         trailing: const Icon(Icons.chevron_right),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= STATUS CHIP =================
//
//   Widget _statusChip(String status) {
//
//     Color color;
//
//     switch (status) {
//       case "loi_sent":
//         color = Colors.blue;
//         break;
//       case "payment_done":
//         color = Colors.green;
//         break;
//       default:
//         color = Colors.orange;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: color,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'create_quotation_screen.dart';
import 'services/quotation_service.dart';
import 'quotation_details_screen.dart';

class QuotationListSales extends StatefulWidget {
  const QuotationListSales({super.key});

  @override
  State<QuotationListSales> createState() => _QuotationListSalesState();
}

class _QuotationListSalesState extends State<QuotationListSales> {
  final _searchCtrl = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ============================
  // FETCH QUOTATIONS (API)
  // ============================

  Future<List<Map<String, dynamic>>> fetchQuotations() async {
    return await QuotationService().getQuotations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Quotations",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),

      // ================= SEARCH =================

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                setState(() => _searchText = v.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search quotation',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ================= LIST =================

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchQuotations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No quotations found"));
                }

                final quotations = snapshot.data!;

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: quotations.length,
                  itemBuilder: (context, index) {
                    final q = quotations[index];

                    final quotationId = q['quotationId'];
                    final status = q['status'] ?? 'quoted';
                    final enquiryTitle =
                        q['enquiryTitle'] ?? '-';

                    final pricing =
                    q['pricing'] as Map<String, dynamic>?;

                    final amount =
                        pricing?['totalAmount'] ?? 0;

                    // ---------- SEARCH FILTER ----------
                    if (_searchText.isNotEmpty &&
                        !quotationId
                            .toLowerCase()
                            .contains(_searchText) &&
                        !enquiryTitle
                            .toLowerCase()
                            .contains(_searchText)) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      margin:
                      const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.all(16),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  QuotationDetailsScreen(
                                    quotationId: quotationId,
                                  ),
                            ),
                          );
                        },

                        title: Text(
                          enquiryTitle.isNotEmpty
                              ? enquiryTitle
                              : "Quotation #$quotationId",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        subtitle: Padding(
                          padding:
                          const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text("Amount: ₹ $amount"),
                              const SizedBox(height: 6),
                              _statusChip(status),
                            ],
                          ),
                        ),

                        trailing:
                        const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ✅ ADD THIS
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateQuotationScreen(),
            ),
          );
        },
      ),
    );
  }

  // ================= STATUS CHIP =================

  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case "quoted":
        color = Colors.orange;
        break;
      case "loi_sent":
        color = Colors.blue;
        break;
      case "accepted":
        color = Colors.green;
        break;
      case "rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
