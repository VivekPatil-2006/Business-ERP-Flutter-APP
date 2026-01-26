import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';
import 'client_quotation_details_screen.dart';


class ClientQuotationListScreen extends StatelessWidget {
  const ClientQuotationListScreen({super.key});

  Color getStatusColor(String status) {
    switch (status) {
      case "sent":
        return Colors.orange;
      case "ack_sent":
        return Colors.blue;
      case "payment_done":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Quotations"),
        backgroundColor: AppColors.darkBlue,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("quotations")
            .where("clientId", isEqualTo: uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          // ---------- LOADING ----------
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ---------- ERROR ----------
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading quotations"),
            );
          }

          // ---------- EMPTY ----------
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No quotations yet"),
            );
          }

          final quotes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: quotes.length,

            itemBuilder: (context, index) {

              final q = quotes[index];
              final data = q.data() as Map<String, dynamic>;

              final amount =
              (data['quotationAmount'] ?? 0).toDouble();

              final status =
                  data['status'] ?? "unknown";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                    ),
                  ],
                ),

                child: ListTile(

                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),

                  // LEFT ICON
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                    getStatusColor(status).withOpacity(0.15),

                    child: Icon(
                      Icons.description,
                      color: getStatusColor(status),
                    ),
                  ),

                  // AMOUNT
                  title: Text(
                    "₹ ${amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // STATUS CHIP
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),

                          decoration: BoxDecoration(
                            color: getStatusColor(status)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: getStatusColor(status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RIGHT ARROW
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ClientQuotationDetailsScreen(
                              quotationId: q.id,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
