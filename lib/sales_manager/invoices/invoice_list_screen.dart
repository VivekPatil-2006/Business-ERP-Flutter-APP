import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/pdf/pdf_utils.dart';


class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {

  String searchText = "";
  String paymentFilter = "all";

  // ======================
  // FILTER TITLE
  // ======================

  String get filterTitle {

    if (paymentFilter == "paid") {
      return "Paid Invoices";
    }

    if (paymentFilter == "unpaid") {
      return "Unpaid Invoices";
    }

    return "All Invoices";
  }

  Color get titleColor {

    if (paymentFilter == "paid") {
      return Colors.green;
    }

    if (paymentFilter == "unpaid") {
      return Colors.red;
    }

    return Colors.black;
  }

  // ======================
  // FILTER LOGIC
  // ======================

  bool filterInvoice(QueryDocumentSnapshot doc) {

    final invoiceNumber =
    (doc['invoiceNumber'] ?? "").toString().toLowerCase();

    final paymentStatus =
    doc.data().toString().contains('paymentStatus')
        ? (doc['paymentStatus'] ?? "unpaid")
        .toString()
        .toLowerCase()
        : "unpaid";

    final matchSearch =
    invoiceNumber.contains(searchText.toLowerCase());

    final matchPayment =
    paymentFilter == "all"
        ? true
        : paymentStatus == paymentFilter;

    return matchSearch && matchPayment;
  }

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ======================
        // TITLE
        // ======================

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),

          child: Text(
            filterTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
        ),

        // ======================
        // SEARCH + FILTER BAR
        // ======================

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),

          child: Row(
            children: [

              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search Invoice Number",
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
                value: paymentFilter,

                items: const [

                  DropdownMenuItem(
                    value: "all",
                    child: Text("All"),
                  ),

                  DropdownMenuItem(
                    value: "paid",
                    child: Text("Paid"),
                  ),

                  DropdownMenuItem(
                    value: "unpaid",
                    child: Text("Unpaid"),
                  ),
                ],

                onChanged: (val) {
                  setState(() => paymentFilter = val!);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ======================
        // INVOICE LIST
        // ======================

        Expanded(
          child: StreamBuilder<QuerySnapshot>(

            stream: FirebaseFirestore.instance
                .collection("invoices")
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
                    child: Text("No Invoices Found"));
              }

              final invoices =
              snapshot.data!.docs.where(filterInvoice).toList();

              if (invoices.isEmpty) {
                return const Center(
                    child: Text("No Matching Invoices"));
              }

              return ListView.builder(
                itemCount: invoices.length,

                itemBuilder: (context, index) {

                  final inv = invoices[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6),

                    child: ListTile(

                      title: Text(
                        inv['invoiceNumber'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),

                      subtitle: Text(
                        DateFormat.yMMMd()
                            .format(inv['date'].toDate()),
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // ---------------- VIEW PDF ----------------

                          if (inv['pdfUrl'] != "")

                            IconButton(
                              icon: const Icon(Icons.visibility),
                              tooltip: "View PDF",

                              onPressed: () {

                                PdfUtils.openPdf(inv['pdfUrl']);
                              },
                            ),

                          // ---------------- DOWNLOAD PDF ----------------

                          if (inv['pdfUrl'] != "")

                            IconButton(
                              icon: const Icon(Icons.download),
                              tooltip: "Download PDF",

                              onPressed: () async {

                                final path = await PdfUtils.downloadPdf(

                                  url: inv['pdfUrl'],
                                  fileName: inv['invoiceNumber'],
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Downloaded to $path")),
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
    );
  }
}
