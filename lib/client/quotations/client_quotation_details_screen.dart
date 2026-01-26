import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/pdf/invoice_pdf_service.dart';
import '../../core/pdf/pdf_utils.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/theme/app_colors.dart';
import '../loi/client_loi_upload_screen.dart';


class ClientQuotationDetailsScreen extends StatefulWidget {

  final String quotationId;

  const ClientQuotationDetailsScreen({
    super.key,
    required this.quotationId,
  });

  @override
  State<ClientQuotationDetailsScreen> createState() =>
      _ClientQuotationDetailsScreenState();
}

class _ClientQuotationDetailsScreenState
    extends State<ClientQuotationDetailsScreen> {

  bool paying = false;

  // =========================
  // STATUS → STEP INDEX
  // =========================

  int getStepIndex(String status) {
    switch (status) {
      case "sent":
        return 0;
      case "loi_sent":
        return 1;
      case "ack_sent":
        return 2;
      case "payment_done":
        return 3;
      default:
        return 0;
    }
  }

  // =========================
  // PAYMENT + INVOICE FLOW
  // =========================

  Future<void> makePayment(Map<String, dynamic> quoteData) async {

    try {

      setState(() => paying = true);

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final amount =
      (quoteData['quotationAmount'] ?? 0).toDouble();

      final product =
          quoteData['productSnapshot'] ?? {};

      // ---------------------------
      // GENERATE INVOICE PDF
      // ---------------------------

      final invoiceFile =
      await InvoicePdfService().generateInvoicePdf(

        quotationId: widget.quotationId,

        productName:
        product['productName'] ?? "Service",

        amount: amount,

        gst:
        (product['cgstPercent'] ?? 0) +
            (product['sgstPercent'] ?? 0),
      );

      // ---------------------------
      // UPLOAD TO CLOUDINARY
      // ---------------------------

      final invoiceUrl =
      await CloudinaryService().uploadFile(invoiceFile);

      // ---------------------------
      // CREATE PAYMENT RECORD
      // ---------------------------

      await FirebaseFirestore.instance
          .collection("payments")
          .add({

        "quotationId": widget.quotationId,

        "clientId": uid,

        "companyId": quoteData['companyId'] ?? "",

        "amount": amount,

        "phase": "phase1",

        "paymentType": "online",

        "paymentMode": "upi",

        "status": "completed",

        "invoicePdfUrl": invoiceUrl,

        "createdAt": Timestamp.now(),
      });

      // ---------------------------
      // UPDATE QUOTATION STATUS
      // ---------------------------

      await FirebaseFirestore.instance
          .collection("quotations")
          .doc(widget.quotationId)
          .update({

        "status": "payment_done",
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful")),
      );

    } catch (e) {

      debugPrint("Payment Error => $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Failed")),
      );

    } finally {

      if (mounted) {
        setState(() => paying = false);
      }
    }
  }

  // =========================
  // FETCH PAYMENT INVOICE
  // =========================

  Future<String?> fetchInvoiceUrl() async {

    final snap = await FirebaseFirestore.instance
        .collection("payments")
        .where("quotationId", isEqualTo: widget.quotationId)
        .where("status", isEqualTo: "completed")
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    return snap.docs.first['invoicePdfUrl'];
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quotation Details"),
        backgroundColor: AppColors.darkBlue,
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("quotations")
            .doc(widget.quotationId)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
          snapshot.data!.data() as Map<String, dynamic>;

          final product =
              data['productSnapshot'] ?? {};

          final status =
              data['status'] ?? "sent";

          final currentStep = getStepIndex(status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                buildTimeline(currentStep),

                const SizedBox(height: 20),

                buildRow("Product",
                    product['productName'] ?? "-"),

                buildRow("Final Amount",
                    "₹ ${data['quotationAmount']}"),

                const Divider(height: 30),

                buildRow("Status", status.toUpperCase()),

                const SizedBox(height: 20),

                // ================= LOI =================

                if (status == "sent")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: const Text("UPLOAD LOI"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClientLoiUploadScreen(
                                  quotationId: widget.quotationId,
                                ),
                          ),
                        );
                      },
                    ),
                  ),

                // ================= PAY =================

                if (status == "ack_sent")

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),

                      onPressed: paying
                          ? null
                          : () => makePayment(data),

                      child: paying
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text("PAY & GENERATE INVOICE"),
                    ),
                  ),

                // ================= DOWNLOAD INVOICE =================

                if (status == "payment_done")

                  FutureBuilder<String?>(
                    future: fetchInvoiceUrl(),

                    builder: (context, invoiceSnap) {

                      if (!invoiceSnap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        );
                      }

                      final url = invoiceSnap.data;

                      if (url == null) {
                        return const Text("Invoice not found");
                      }

                      return ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text("DOWNLOAD INVOICE"),

                        onPressed: () {
                          PdfUtils.openPdf(url);
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // UI HELPERS
  // =====================================================

  Widget buildTimeline(int currentStep) {

    final steps = [
      "Quotation",
      "LOI",
      "ACK",
      "Payment",
      "Invoice",
    ];

    return Row(
      children: List.generate(steps.length, (index) {

        final active = index <= currentStep;

        return Expanded(
          child: Column(
            children: [

              CircleAvatar(
                radius: 12,
                backgroundColor:
                active ? Colors.green : Colors.grey,
              ),

              const SizedBox(height: 5),

              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 11,
                  color: active ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildRow(String title, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [

          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
