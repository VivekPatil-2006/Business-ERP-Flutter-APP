import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String searchText = "";

  String companyId = "";
  bool loadingCompany = true;

  final Map<String, Map<String, dynamic>> clientCache = {};

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    loadCompanyId();
  }

  // ================= LOAD SALES MANAGER COMPANY =================

  Future<void> loadCompanyId() async {

    final uid = auth.currentUser!.uid;

    final snap = await firestore
        .collection("sales_managers")
        .doc(uid)
        .get();

    companyId = snap.data()?['companyId'] ?? "";

    setState(() => loadingCompany = false);
  }

  // ================= FETCH CLIENT (CACHE) =================

  Future<Map<String, dynamic>?> fetchClient(String id) async {

    if (clientCache.containsKey(id)) {
      return clientCache[id];
    }

    final snap = await firestore
        .collection("clients")
        .doc(id)
        .get();

    if (!snap.exists) return null;

    clientCache[id] = snap.data()!;
    return clientCache[id];
  }

  @override
  Widget build(BuildContext context) {

    if (loadingCompany) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Payment Receipts"),
      ),

      body: Column(
        children: [

          // ================= SEARCH =================

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
                setState(() =>
                searchText = val.trim().toLowerCase());
              },
            ),
          ),

          // ================= PAYMENT LIST =================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: firestore
                  .collection("payments")
                  .where("companyId", isEqualTo: companyId) // ✅ COMPANY FILTER
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
                      child: Text("No Payments Found"));
                }

                // ================= SEARCH FILTER =================

                final payments = snapshot.data!.docs.where((doc) {

                  final data =
                  doc.data() as Map<String, dynamic>;

                  final invoice =
                  (data['invoiceNumber'] ?? "")
                      .toString()
                      .toLowerCase();

                  return invoice.contains(searchText);

                }).toList();

                if (payments.isEmpty) {
                  return const Center(
                      child: Text("No Matching Records"));
                }

                return ListView.builder(

                  padding: const EdgeInsets.only(bottom: 12),

                  itemCount: payments.length,

                  itemBuilder: (context, index) {

                    final pay = payments[index];
                    final payData =
                    pay.data() as Map<String, dynamic>;

                    final clientId = payData['clientId'];

                    if (clientId == null) {
                      return const SizedBox();
                    }

                    final status =
                    (payData['status'] ?? "pending").toString();

                    final amount =
                    (payData['amount'] ?? 0).toDouble();

                    final Timestamp? ts =
                    payData['createdAt'];

                    final date =
                    ts != null ? ts.toDate() : DateTime.now();

                    // ================= PAYMENT REFERENCE =================

                    String paymentRef = "-";

                    if (payData['paymentMode'] == "online" &&
                        payData['onlineDetails'] != null) {

                      paymentRef =
                          payData['onlineDetails']
                          ['transactionId'] ??
                              "-";
                    }

                    if (payData['paymentMode'] == "offline" &&
                        payData['offlineDetails'] != null) {

                      paymentRef =
                          payData['offlineDetails']
                          ['chequeNumber'] ??
                              "-";
                    }

                    return FutureBuilder<Map<String, dynamic>?>(

                      future: fetchClient(clientId),

                      builder: (context, clientSnap) {

                        if (!clientSnap.hasData) {
                          return const SizedBox();
                        }

                        final client = clientSnap.data!;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 6,
                                color: Colors.black
                                    .withOpacity(0.05),
                              ),
                            ],
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(14),

                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
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
                                          payData['invoiceNumber'] ?? "-",
                                          style: const TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6),

                                      decoration: BoxDecoration(
                                        color: status == "completed"
                                            ? Colors.green.shade100
                                            : Colors.orange.shade100,
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),

                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight:
                                          FontWeight.bold,
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
                                  client['companyName'] ?? "-",
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
                                  payData['paymentMode'] ?? "-",
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
