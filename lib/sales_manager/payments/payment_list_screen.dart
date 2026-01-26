import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  String searchText = "";

  bool hasField(QueryDocumentSnapshot doc, String field) {
    return (doc.data() as Map<String, dynamic>).containsKey(field);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Receipts")),
      body: Column(
        children: [
          // ---------------- SEARCH ----------------
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search Invoice Number",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() => searchText = val.trim().toLowerCase());
              },
            ),
          ),

          // ---------------- PAYMENT LIST ----------------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("payments")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, paymentSnapshot) {
                if (paymentSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!paymentSnapshot.hasData ||
                    paymentSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Payments Found"));
                }

                final payments = paymentSnapshot.data!.docs;

                return ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final pay = payments[index];
                    final payData =
                    pay.data() as Map<String, dynamic>;

                    // ---------- REQUIRED FIELDS ----------
                    if (!payData.containsKey("invoiceNumber") ||
                        !payData.containsKey("clientId")) {
                      return const SizedBox();
                    }

                    final invoiceNumber =
                    payData['invoiceNumber']
                        .toString()
                        .toLowerCase();

                    // ---------- SEARCH FILTER ----------
                    if (!invoiceNumber.contains(searchText)) {
                      return const SizedBox();
                    }

                    final String clientId = payData['clientId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("clients")
                          .doc(clientId)
                          .get(),
                      builder: (context, clientSnapshot) {
                        if (!clientSnapshot.hasData ||
                            !clientSnapshot.data!.exists) {
                          return const SizedBox();
                        }

                        final clientData = clientSnapshot.data!.data()
                        as Map<String, dynamic>;

                        // ---------- PAYMENT REF ----------
                        String paymentRef = "-";

                        if (payData['paymentMode'] == "online" &&
                            payData.containsKey("onlineDetails")) {
                          paymentRef =
                              payData['onlineDetails']
                              ['transactionId'] ??
                                  "-";
                        }

                        if (payData['paymentMode'] == "offline" &&
                            payData.containsKey("offlineDetails")) {
                          paymentRef =
                              payData['offlineDetails']
                              ['chequeNumber'] ??
                                  "-";
                        }

                        // ---------- UI ----------
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // HEADER
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Invoice: ${payData['invoiceNumber']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Chip(
                                      label: Text(
                                        (payData['status'] ?? "pending")
                                            .toString()
                                            .toUpperCase(),
                                      ),
                                      backgroundColor:
                                      payData['status'] ==
                                          "completed"
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                // DETAILS
                                Text("Payment ID: ${pay.id}"),
                                Text(
                                    "Customer: ${clientData['companyName']}"),
                                Text("Amount: ₹ ${payData['amount']}"),
                                Text(
                                  "Date: ${DateFormat.yMMMd().format(
                                    (payData['createdAt'] as Timestamp)
                                        .toDate(),
                                  )}",
                                ),
                                Text(
                                    "Mode: ${payData['paymentMode']}"),
                                Text("Reference No: $paymentRef"),
                              ],
                            ),
                          ),
                        );
                      },
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
