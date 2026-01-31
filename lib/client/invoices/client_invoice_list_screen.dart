import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../core/pdf/pdf_utils.dart';
import '../../core/theme/app_colors.dart';

class ClientInvoiceListScreen extends StatefulWidget {
  const ClientInvoiceListScreen({super.key});

  @override
  State<ClientInvoiceListScreen> createState() =>
      _ClientInvoiceListScreenState();
}

class _ClientInvoiceListScreenState
    extends State<ClientInvoiceListScreen> {

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  String searchText = "";
  String filterStatus = "all";

  // ======================
  // FILTER LOGIC
  // ======================

  bool filterInvoice(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final paymentStatus =
    (data['paymentStatus'] ?? "").toString().toLowerCase();

    final createdAt = data['createdAt'] as Timestamp?;

    final dateText = createdAt != null
        ? DateFormat.yMMMd().format(createdAt.toDate())
        : "";

    final matchSearch =
    dateText.toLowerCase().contains(searchText.toLowerCase());

    final matchStatus =
        filterStatus == "all" || paymentStatus == filterStatus;

    return matchSearch && matchStatus;
  }

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,

        // 👈 back arrow & menu icon color
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        // 👈 title text color
        title: const Text(
          "My Invoices",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [

          // ================= SEARCH + FILTER =================

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search by date",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() => searchText = val);
                    },
                  ),
                ),

                const SizedBox(width: 10),

                DropdownButton<String>(
                  value: filterStatus,
                  items: const [
                    DropdownMenuItem(value: "all", child: Text("All")),
                    DropdownMenuItem(value: "paid", child: Text("Paid")),
                    DropdownMenuItem(value: "unpaid", child: Text("Unpaid")),
                  ],
                  onChanged: (val) {
                    setState(() => filterStatus = val!);
                  },
                ),
              ],
            ),
          ),

          // ================= LIST =================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("invoices")
                  .where("clientId", isEqualTo: uid)
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No invoices available"));
                }

                final invoices =
                snapshot.data!.docs.where(filterInvoice).toList();

                if (invoices.isEmpty) {
                  return const Center(
                      child: Text("No matching invoices"));
                }

                return ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {

                    final inv = invoices[index];
                    final data =
                    inv.data() as Map<String, dynamic>;

                    final Timestamp? createdAt =
                    data['createdAt'];

                    final String pdfUrl =
                        data['pdfUrl'] ?? "";

                    final String paymentStatus =
                    (data['paymentStatus'] ?? "").toLowerCase();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(

                        leading: Icon(
                          Icons.receipt_long,
                          color: paymentStatus == "paid"
                              ? Colors.green
                              : Colors.orange,
                        ),

                        title: Text(
                          "Invoice #${data['invoiceNumber'] ?? inv.id}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            if (createdAt != null)
                              Text(
                                DateFormat.yMMMd()
                                    .format(createdAt.toDate()),
                              ),

                            const SizedBox(height: 4),

                            Text(
                              paymentStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: paymentStatus == "paid"
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // IconButton(
                            //   icon: const Icon(Icons.visibility),
                            //   onPressed: pdfUrl.isEmpty
                            //       ? null
                            //       : () {
                            //     PdfUtils.openPdf(pdfUrl);
                            //   },
                            // ),

                            // IconButton(
                            //   icon: const Icon(Icons.download),
                            //   onPressed: pdfUrl.isEmpty
                            //       ? null
                            //       : () async {
                            //     await PdfUtils.downloadPdf(
                            //       url: pdfUrl,
                            //       fileName:
                            //       "Invoice_${inv.id}",
                            //     );
                            //   },
                            // ),
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
