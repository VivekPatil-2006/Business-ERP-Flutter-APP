import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/pdf/pdf_utils.dart';


class QuotationListSales extends StatelessWidget {
  const QuotationListSales({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Client LOIs"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("loi")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No LOIs received"));
          }

          final lois = snapshot.data!.docs;

          return ListView.builder(
            itemCount: lois.length,
            itemBuilder: (context, index) {
              final l = lois[index];
              final data = l.data() as Map<String, dynamic>;

              final quotationId = data['quotationId'] ?? 'N/A';
              final status = data['status'] ?? 'unknown';
              final ackPdfUrl = data['ackPdfUrl'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Quotation ID: $quotationId"),
                  subtitle: Text("Status: $status"),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ACCEPT BUTTON
                      if (status == "sent")
                        ElevatedButton(
                          onPressed: () async {
                            // Your ACK logic here
                            // Example:
                            // await NotificationService.sendAck(quotationId);
                          },
                          child: const Text("Accept"),
                        ),

                      // VIEW / DOWNLOAD PDF
                      if (status == "accepted" && ackPdfUrl != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                PdfUtils.openPdf(ackPdfUrl);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () async {
                                await PdfUtils.downloadPdf(
                                  url: ackPdfUrl,
                                  fileName: "ACK_$quotationId",
                                );
                              },
                            ),
                          ],
                        ),

                      // ACCEPTED TEXT (fallback)
                      if (status == "accepted" && ackPdfUrl == null)
                        const Text(
                          "Accepted",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
