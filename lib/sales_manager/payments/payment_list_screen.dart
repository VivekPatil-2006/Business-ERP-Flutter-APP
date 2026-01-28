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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Payment Receipts"),
      ),

      body: Column(
        children: [

          // ================= SEARCH BAR =================

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Invoice Number",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),

              onChanged: (val) {
                setState(() => searchText = val.trim().toLowerCase());
              },
            ),
          ),

          // ================= PAYMENT LIST =================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("payments")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Payments Found"));
                }

                final payments = snapshot.data!.docs;

                return ListView.builder(

                  padding: const EdgeInsets.only(bottom: 12),

                  itemCount: payments.length,

                  itemBuilder: (context, index) {

                    final pay = payments[index];
                    final payData = pay.data() as Map<String, dynamic>;

                    // ---------------- REQUIRED FIELDS ----------------

                    if (!payData.containsKey("invoiceNumber") ||
                        !payData.containsKey("clientId")) {
                      return const SizedBox();
                    }

                    final invoiceNumber =
                    payData['invoiceNumber']
                        .toString()
                        .toLowerCase();

                    // ---------------- SEARCH FILTER ----------------

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

                        final clientData =
                        clientSnapshot.data!.data()
                        as Map<String, dynamic>;

                        // ---------------- PAYMENT REFERENCE ----------------

                        String paymentRef = "-";

                        if (payData['paymentMode'] == "online" &&
                            payData.containsKey("onlineDetails")) {
                          paymentRef =
                              payData['onlineDetails']['transactionId'] ?? "-";
                        }

                        if (payData['paymentMode'] == "offline" &&
                            payData.containsKey("offlineDetails")) {
                          paymentRef =
                              payData['offlineDetails']['chequeNumber'] ?? "-";
                        }

                        final status =
                        (payData['status'] ?? "pending").toString();

                        final amount =
                        (payData['amount'] ?? 0).toDouble();

                        final date =
                        (payData['createdAt'] as Timestamp).toDate();

                        // ---------------- CARD UI ----------------

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),

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

                          child: Padding(
                            padding: const EdgeInsets.all(14),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // ================= HEADER =================

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [

                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [

                                        const Text(
                                          "Invoice",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(height: 2),

                                        Text(
                                          payData['invoiceNumber'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),

                                      decoration: BoxDecoration(
                                        color: status == "completed"
                                            ? Colors.green.shade100
                                            : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: status == "completed"
                                              ? Colors.green.shade800
                                              : Colors.orange.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(height: 22),

                                // ================= DETAILS =================

                                buildInfoRow(
                                  Icons.business,
                                  "Customer",
                                  clientData['companyName'],
                                ),

                                buildInfoRow(
                                  Icons.currency_rupee,
                                  "Amount",
                                  "₹ ${amount.toStringAsFixed(2)}",
                                ),

                                buildInfoRow(
                                  Icons.calendar_month,
                                  "Date",
                                  DateFormat.yMMMd().format(date),
                                ),

                                buildInfoRow(
                                  Icons.payment,
                                  "Mode",
                                  payData['paymentMode'],
                                ),

                                buildInfoRow(
                                  Icons.confirmation_number,
                                  "Reference",
                                  paymentRef,
                                ),
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

  // ================= INFO ROW =================

  Widget buildInfoRow(
      IconData icon,
      String label,
      String value,
      ) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        children: [

          Icon(icon, size: 16, color: Colors.grey),

          const SizedBox(width: 8),

          SizedBox(
            width: 85,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
