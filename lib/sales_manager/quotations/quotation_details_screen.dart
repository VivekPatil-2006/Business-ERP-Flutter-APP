import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../core/theme/app_colors.dart';

class QuotationDetailsScreen extends StatelessWidget {

  final String quotationId;
  final String clientId;
  final String productId;

  const QuotationDetailsScreen({
    super.key,
    required this.quotationId,
    required this.clientId,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Quotation Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<DocumentSnapshot>(

        future: FirebaseFirestore.instance
            .collection("quotations")
            .doc(quotationId)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Quotation not found"));
          }

          final data =
          snapshot.data!.data() as Map<String, dynamic>;

          final productSnapshot =
              data['productSnapshot'] ?? {};

          final status =
              data['status'] ?? "sent";

          final amount =
              data['quotationAmount'] ?? 0;

          final salesManagerId =
          data['salesManagerId'];

          return SingleChildScrollView(

            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                section("Quotation Info"),

                info("Quotation ID", quotationId),
                info("Status", status.toUpperCase()),
                info("Final Amount", "₹ $amount"),

                const Divider(height: 30),

                section("Product Info"),

                info("Product Name",
                    productSnapshot['productName']),

                info("Quantity",
                    productSnapshot['quantity']),

                info("Base Price",
                    productSnapshot['basePrice']),

                info("Discount %",
                    productSnapshot['discountPercent']),

                info("Extra Discount %",
                    productSnapshot['extraDiscountPercent']),

                info("CGST %",
                    productSnapshot['cgstPercent']),

                info("SGST %",
                    productSnapshot['sgstPercent']),

                const SizedBox(height: 30),

                // ================= AI BUTTON =================

                _SendAiQuotationButton(
                  quotationId: quotationId,
                  salesManagerId: salesManagerId,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget section(String title) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget info(String label, dynamic value) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Row(
        children: [

          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// ================= AI SEND BUTTON =========================
// ==========================================================

class _SendAiQuotationButton extends StatefulWidget {

  final String quotationId;
  final String salesManagerId;

  const _SendAiQuotationButton({
    required this.quotationId,
    required this.salesManagerId,
  });

  @override
  State<_SendAiQuotationButton> createState() =>
      _SendAiQuotationButtonState();
}

class _SendAiQuotationButtonState
    extends State<_SendAiQuotationButton> {

  bool sending = false;

  // ✅ YOUR HOSTED API BASE URL
  final String baseUrl =
      "https://nodeapi-backend-1.onrender.com/api/quotations";
  //https://nodeapi-backend-1.onrender.com

  // ================= SEND FLOW =================

  Future<void> sendQuotationUsingAI() async {

    try {

      setState(() => sending = true);

      final id = widget.quotationId;

      // ================= 1️⃣ GENERATE AI CONTENT =================

      final aiRes = await http.post(
        Uri.parse("$baseUrl/$id/generate-ai"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (aiRes.statusCode != 200) {
        debugPrint("AI Error => ${aiRes.body}");
        throw "AI generation failed";
      }

      // ================= 2️⃣ GENERATE PDF =================

      final pdfRes = await http.post(
        Uri.parse("$baseUrl/$id/generate-pdf"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (pdfRes.statusCode != 200) {
        debugPrint("PDF Error => ${pdfRes.body}");
        throw "PDF generation failed";
      }

      // ================= 3️⃣ SEND FIREBASE MAIL =================

      final sendRes = await http.post(
        Uri.parse("$baseUrl/$id/sendFirebase"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (sendRes.statusCode != 200) {
        debugPrint("Send Error => ${sendRes.body}");
        throw "Mail sending failed";
      }

      final response =
      jsonDecode(sendRes.body);

      // ================= SUCCESS =================

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Quotation sent successfully to ${response['sentTo']}",
            ),
          ),
        );
      }

    } catch (e) {

      debugPrint("AI Send Error => $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Failed to send quotation. Try again.",
            ),
          ),
        );
      }

    } finally {

      if (mounted) {
        setState(() => sending = false);
      }
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,

      child: ElevatedButton.icon(

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 7,
        ),

        icon: sending
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.auto_awesome,
          color: Colors.white,
        ),

        label: Text(
          sending
              ? "AI Processing..."
              : "Send Quotation Using AI",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            fontSize: 15,
          ),
        ),

        onPressed: sending
            ? null
            : sendQuotationUsingAI,
      ),
    );
  }
}
