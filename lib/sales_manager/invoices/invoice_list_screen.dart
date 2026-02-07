// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// import '../../core/pdf/pdf_utils.dart';
//
// class InvoiceListScreen extends StatefulWidget {
//   const InvoiceListScreen({super.key});
//
//   @override
//   State<InvoiceListScreen> createState() => _InvoiceListScreenState();
// }
//
// class _InvoiceListScreenState extends State<InvoiceListScreen> {
//
//   final firestore = FirebaseFirestore.instance;
//   final auth = FirebaseAuth.instance;
//
//   String searchText = "";
//   String paymentFilter = "all";
//
//   String? companyId;
//   bool loadingCompany = true;
//
//   // ======================
//   // LOAD COMPANY ID
//   // ======================
//
//   @override
//   void initState() {
//     super.initState();
//     loadCompany();
//   }
//
//   Future<void> loadCompany() async {
//
//     final uid = auth.currentUser!.uid;
//
//     final snap = await firestore
//         .collection("sales_managers")
//         .doc(uid)
//         .get();
//
//     companyId = snap.data()?['companyId'];
//
//     setState(() => loadingCompany = false);
//   }
//
//   // ======================
//   // FILTER LOGIC
//   // ======================
//
//   bool filterInvoice(QueryDocumentSnapshot doc) {
//
//     final data = doc.data() as Map<String, dynamic>;
//
//     final String invoiceNumber =
//     (data['invoiceNumber'] ?? "").toString().toLowerCase();
//
//     final String paymentStatus =
//     (data['paymentStatus'] ?? "unpaid").toString().toLowerCase();
//
//     final bool matchSearch =
//     invoiceNumber.contains(searchText.toLowerCase());
//
//     final bool matchPayment =
//         paymentFilter == "all" || paymentStatus == paymentFilter;
//
//     return matchSearch && matchPayment;
//   }
//
//   // ======================
//   // UI
//   // ======================
//
//   @override
//   Widget build(BuildContext context) {
//
//     if (loadingCompany) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (companyId == null) {
//       return const Center(child: Text("Company not assigned"));
//     }
//
//     return Column(
//       children: [
//
//         // ================= SEARCH + FILTER =================
//
//         Padding(
//           padding: const EdgeInsets.all(10),
//
//           child: Row(
//             children: [
//
//               Expanded(
//                 child: TextField(
//                   decoration: const InputDecoration(
//                     hintText: "Search Invoice",
//                     prefixIcon: Icon(Icons.search),
//                     border: OutlineInputBorder(),
//                   ),
//
//                   onChanged: (val) {
//                     setState(() => searchText = val.trim());
//                   },
//                 ),
//               ),
//
//               const SizedBox(width: 10),
//
//               DropdownButton<String>(
//                 value: paymentFilter,
//
//                 items: const [
//
//                   DropdownMenuItem(value: "all", child: Text("All")),
//                   DropdownMenuItem(value: "paid", child: Text("Paid")),
//                   DropdownMenuItem(value: "unpaid", child: Text("Unpaid")),
//                 ],
//
//                 onChanged: (val) {
//                   setState(() => paymentFilter = val!);
//                 },
//               ),
//             ],
//           ),
//         ),
//
//         // ================= REALTIME INVOICE LIST =================
//
//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//
//             stream: firestore
//                 .collection("invoices")
//                 .where("companyId", isEqualTo: companyId)
//                 .orderBy("createdAt", descending: true)
//                 .snapshots(),
//
//             builder: (context, snapshot) {
//
//               // ---------- LOADING ----------
//
//               if (snapshot.connectionState ==
//                   ConnectionState.waiting) {
//                 return const Center(
//                     child: CircularProgressIndicator());
//               }
//
//               // ---------- ERROR ----------
//
//               if (snapshot.hasError) {
//                 return const Center(
//                     child: Text("Failed to load invoices"));
//               }
//
//               // ---------- EMPTY ----------
//
//               if (!snapshot.hasData ||
//                   snapshot.data!.docs.isEmpty) {
//                 return const Center(
//                     child: Text("No invoices found"));
//               }
//
//               final invoices =
//               snapshot.data!.docs.where(filterInvoice).toList();
//
//               if (invoices.isEmpty) {
//                 return const Center(
//                     child: Text("No matching invoices"));
//               }
//
//               // ---------- LIST ----------
//
//               return ListView.builder(
//
//                 physics: const BouncingScrollPhysics(),
//
//                 itemCount: invoices.length,
//
//                 itemBuilder: (context, index) {
//
//                   final inv = invoices[index];
//                   final data =
//                   inv.data() as Map<String, dynamic>;
//
//                   final Timestamp? createdAt =
//                   data['createdAt'];
//
//                   final String date = createdAt != null
//                       ? DateFormat.yMMMd()
//                       .format(createdAt.toDate())
//                       : "-";
//
//                   final String invoiceNo =
//                       data['invoiceNumber'] ?? inv.id;
//
//                   final String pdfUrl =
//                       data['pdfUrl'] ?? "";
//
//                   final String paymentStatus =
//                   (data['paymentStatus'] ?? "unpaid")
//                       .toString()
//                       .toLowerCase();
//
//                   return Card(
//                     margin: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 6),
//
//                     child: ListTile(
//
//                       leading: Icon(
//                         Icons.receipt_long,
//                         color: paymentStatus == "paid"
//                             ? Colors.green
//                             : Colors.orange,
//                       ),
//
//                       title: Text(
//                         invoiceNo,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold),
//                       ),
//
//                       subtitle: Column(
//                         crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                         children: [
//
//                           Text(date),
//
//                           const SizedBox(height: 4),
//
//                           Text(
//                             paymentStatus.toUpperCase(),
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: paymentStatus == "paid"
//                                   ? Colors.green
//                                   : Colors.orange,
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//
//                           if (pdfUrl.isNotEmpty)
//
//                             IconButton(
//                               icon: const Icon(Icons.visibility),
//                               onPressed: () {
//                                 PdfUtils.openPdf(pdfUrl);
//                               },
//                             ),
//
//                           if (pdfUrl.isNotEmpty)
//
//                             IconButton(
//                               icon: const Icon(Icons.download),
//                               onPressed: () async {
//
//                                 final path =
//                                 await PdfUtils.downloadPdf(
//                                   url: pdfUrl,
//                                   fileName: invoiceNo,
//                                 );
//
//                                 if (mounted) {
//                                   ScaffoldMessenger.of(context)
//                                       .showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                           "Downloaded to $path"),
//                                     ),
//                                   );
//                                 }
//                               },
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/pdf/pdf_utils.dart';
import '../../core/theme/app_colors.dart';
import 'services/invoice_service.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  String searchText = "";
  String paymentFilter = "all";

  // ======================
  // FETCH INVOICES (API)
  // ======================

  Future<List<Map<String, dynamic>>> fetchInvoices() async {
    return await InvoiceService().getInvoices();
  }

  // ======================
  // FILTER LOGIC
  // ======================

  bool _filterInvoice(Map<String, dynamic> inv) {
    final invoiceNo =
    (inv['invoiceNumber'] ?? inv['invoiceId'] ?? "")
        .toString()
        .toLowerCase();

    final status =
    (inv['status'] ?? "pending").toString().toLowerCase();

    final bool matchSearch =
    invoiceNo.contains(searchText.toLowerCase());

    final bool matchPayment =
        paymentFilter == "all" || status == paymentFilter;

    return matchSearch && matchPayment;
  }

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     "Invoices",
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor: AppColors.darkBlue,
      //   foregroundColor: Colors.white,
      // ),

      body: Column(
        children: [
          // ================= SEARCH + FILTER =================

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search Invoice",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() => searchText = val.trim());
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: paymentFilter,
                  items: const [
                    DropdownMenuItem(
                        value: "all", child: Text("All")),
                    DropdownMenuItem(
                        value: "paid", child: Text("Paid")),
                    DropdownMenuItem(
                        value: "pending", child: Text("Pending")),
                  ],
                  onChanged: (val) {
                    setState(() => paymentFilter = val!);
                  },
                ),
              ],
            ),
          ),

          // ================= INVOICE LIST =================

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchInvoices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Failed to load invoices"));
                }

                final invoices =
                (snapshot.data ?? []).where(_filterInvoice).toList();

                if (invoices.isEmpty) {
                  return const Center(
                      child: Text("No invoices found"));
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final inv = invoices[index];

                    final createdAt = inv['createdAt'] != null
                        ? DateTime.tryParse(inv['createdAt'])
                        : null;

                    final date = createdAt != null
                        ? DateFormat.yMMMd().format(createdAt)
                        : "-";

                    final invoiceNo =
                        inv['invoiceNumber'] ?? inv['invoiceId'];

                    final pdfUrl = inv['pdfUrl'] ?? "";

                    final status =
                    (inv['status'] ?? "pending").toString().toLowerCase();

                    final amount =
                        inv['totalAmount'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          Icons.receipt_long,
                          color: status == "paid"
                              ? Colors.green
                              : Colors.orange,
                        ),

                        title: Text(
                          invoiceNo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(date),
                            const SizedBox(height: 4),
                            Text(
                              "₹ $amount • ${status.toUpperCase()}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: status == "paid"
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (pdfUrl.isNotEmpty)
                              IconButton(
                                icon:
                                const Icon(Icons.visibility),
                                onPressed: () {
                                  PdfUtils.openPdf(pdfUrl);
                                },
                              ),

                            if (pdfUrl.isNotEmpty)
                              IconButton(
                                icon:
                                const Icon(Icons.download),
                                onPressed: () async {
                                  final path =
                                  await PdfUtils.downloadPdf(
                                    url: pdfUrl,
                                    fileName: invoiceNo,
                                  );

                                  if (mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Downloaded to $path"),
                                      ),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
