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

  final uid = FirebaseAuth.instance.currentUser!.uid;

  String searchText = "";
  String filterStatus = "all";

  // ======================
  // FILTER LOGIC
  // ======================

  bool filterInvoice(QueryDocumentSnapshot doc) {

    final data = doc.data() as Map<String, dynamic>;

    final status =
    (data['status'] ?? "").toString().toLowerCase();

    final invoiceUrl =
        data['invoicePdfUrl'] ?? "";

    final createdAt =
    data['createdAt'] as Timestamp?;

    final dateText = createdAt != null
        ? DateFormat.yMMMd().format(createdAt.toDate())
        : "";

    final matchSearch =
    dateText.toLowerCase().contains(searchText.toLowerCase());

    final matchStatus = filterStatus == "all"
        ? true
        : status == filterStatus;

    // Only show invoices having PDF
    final hasInvoice = invoiceUrl.toString().isNotEmpty;

    return matchSearch && matchStatus && hasInvoice;
  }

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Invoices"),
        backgroundColor: AppColors.darkBlue,
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
                    DropdownMenuItem(
                        value: "all", child: Text("All")),
                    DropdownMenuItem(
                        value: "payment_done",
                        child: Text("Paid")),
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
                  .collection("quotations")
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

                    final amount =
                        data['quotationAmount'] ?? 0;

                    final createdAt =
                    data['createdAt'] as Timestamp;

                    final invoiceUrl =
                    data['invoicePdfUrl'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),

                      child: ListTile(

                        leading: const Icon(
                          Icons.receipt_long,
                          color: Colors.green,
                        ),

                        title: Text(
                          "₹ $amount",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          DateFormat.yMMMd()
                              .format(createdAt.toDate()),
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                PdfUtils.openPdf(invoiceUrl);
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () async {
                                await PdfUtils.downloadPdf(
                                  url: invoiceUrl,
                                  fileName:
                                  "Invoice_${inv.id}",
                                );
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
