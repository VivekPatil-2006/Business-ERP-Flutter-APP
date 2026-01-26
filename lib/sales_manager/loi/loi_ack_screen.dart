import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/pdf/ack_pdf_service.dart';
import '../../core/pdf/pdf_utils.dart';
import '../../core/services/notification_service.dart';
import 'loi_file_viewer.dart';

class LoiAckScreen extends StatelessWidget {
  const LoiAckScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("LOI Requests"),
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
            return const Center(child: Text("No LOI Requests"));
          }

          final lois = snapshot.data!.docs;

          return ListView.builder(
            itemCount: lois.length,

            itemBuilder: (context, index) {

              final l = lois[index];
              final data = l.data() as Map<String, dynamic>;

              final status = data['status'] ?? "sent";
              final quotationId = data['quotationId'];
              final clientId = data['clientId'];
              final loiUrl = data['attachmentUrl'];
              final ackPdfUrl = data['ackPdfUrl'];

              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ================= HEADER =================

                      Text(
                        "Quotation ID: $quotationId",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Status: ${status.toUpperCase()}",
                        style: TextStyle(
                          color: status == "accepted"
                              ? Colors.green
                              : status == "rejected"
                              ? Colors.red
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= VIEW BUTTONS =================

                      Row(
                        children: [

                          // VIEW LOI
                          OutlinedButton.icon(
                            icon: const Icon(Icons.visibility),
                            label: const Text("View LOI"),

                    onPressed: loiUrl == null ? null : () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoiFileViewer(
                            url: loiUrl,
                            fileType: data['fileType'] ?? "image",
                          ),
                        ),
                      );
                    },
                          ),

                          const SizedBox(width: 10),

                          // VIEW ACK
                          if (ackPdfUrl != null && ackPdfUrl != "")
                            OutlinedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text("View ACK"),

                              onPressed: () {
                                PdfUtils.openPdf(ackPdfUrl);
                              },
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ================= ACTION BUTTONS =================

                      if (status == "sent")

                        Row(
                          children: [

                            // ================= ACCEPT =================

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),

                                onPressed: () async {

                                  // Fetch quotation data
                                  final quoteDoc =
                                  await FirebaseFirestore.instance
                                      .collection("quotations")
                                      .doc(quotationId)
                                      .get();

                                  if (!quoteDoc.exists) return;

                                  final quoteData =
                                  quoteDoc.data() as Map<String, dynamic>;

                                  final clientName =
                                      quoteData['clientName'] ?? "Client";

                                  // Generate ACK PDF
                                  final ackUrl =
                                  await AckPdfService()
                                      .generateAckPdf(
                                    quotationId: quotationId,
                                    clientName: clientName,
                                    decision: "ACCEPTED",
                                  );

                                  // Update LOI
                                  await FirebaseFirestore.instance
                                      .collection("loi")
                                      .doc(l.id)
                                      .update({
                                    "status": "accepted",
                                    "ackPdfUrl": ackUrl,
                                  });

                                  // Enable Payment in Quotation
                                  await FirebaseFirestore.instance
                                      .collection("quotations")
                                      .doc(quotationId)
                                      .update({
                                    "status": "ack_sent",
                                    "paymentEnabled": true,
                                    "ackPdfUrl": ackUrl,
                                  });

                                  // Notify Client
                                  await NotificationService()
                                      .sendNotification(
                                    userId: clientId,
                                    role: "client",
                                    title: "LOI Approved",
                                    message:
                                    "Your LOI has been approved. You can proceed with payment.",
                                    type: "ack",
                                    referenceId: quotationId,
                                  );
                                },

                                child: const Text("ACCEPT"),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // ================= REJECT =================

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),

                                onPressed: () async {

                                  final quoteDoc =
                                  await FirebaseFirestore.instance
                                      .collection("quotations")
                                      .doc(quotationId)
                                      .get();

                                  if (!quoteDoc.exists) return;

                                  final quoteData =
                                  quoteDoc.data() as Map<String, dynamic>;

                                  final clientName =
                                      quoteData['clientName'] ?? "Client";

                                  final ackUrl =
                                  await AckPdfService()
                                      .generateAckPdf(
                                    quotationId: quotationId,
                                    clientName: clientName,
                                    decision: "REJECTED",
                                  );

                                  await FirebaseFirestore.instance
                                      .collection("loi")
                                      .doc(l.id)
                                      .update({
                                    "status": "rejected",
                                    "ackPdfUrl": ackUrl,
                                  });

                                  await FirebaseFirestore.instance
                                      .collection("quotations")
                                      .doc(quotationId)
                                      .update({
                                    "status": "rejected",
                                    "ackPdfUrl": ackUrl,
                                  });

                                  await NotificationService()
                                      .sendNotification(
                                    userId: clientId,
                                    role: "client",
                                    title: "LOI Rejected",
                                    message:
                                    "Your LOI was rejected. Please contact sales team.",
                                    type: "ack",
                                    referenceId: quotationId,
                                  );
                                },

                                child: const Text("REJECT"),
                              ),
                            ),
                          ],
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
