import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';


class ClientPaymentScreen extends StatefulWidget {
  const ClientPaymentScreen({super.key});

  @override
  State<ClientPaymentScreen> createState() => _ClientPaymentScreenState();
}

class _ClientPaymentScreenState extends State<ClientPaymentScreen> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? selectedInvoiceId;
  String phase = "phase1";
  String paymentMode = "upi";

  final amountCtrl = TextEditingController();

  File? proofFile;
  bool loading = false;

  // ================= FETCH UNPAID INVOICES =================

  Future<List<QueryDocumentSnapshot>> fetchInvoices() async {
    final snap = await firestore
        .collection('invoices')
        .where("paymentStatus", isEqualTo: "unpaid")
        .get();

    return snap.docs;
  }

  // ================= PICK IMAGE =================

  pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        proofFile = File(picked.path);
      });
    }
  }

  // ================= SUBMIT PAYMENT =================

  submitPayment() async {

    if (proofFile == null ||
        selectedInvoiceId == null ||
        amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete all fields")),
      );
      return;
    }

    setState(() => loading = true);

    final proofUrl =
    await CloudinaryService().uploadFile(proofFile!);

    await firestore.collection('payments').add({

      "invoiceId": selectedInvoiceId,
      "clientId": "0Tsr8JPgnOPGA83IxlOiltATJTp1", // replace with auth uid
      "amount": double.parse(amountCtrl.text),
      "phase": phase,
      "paymentMode": paymentMode,
      "paymentType": "online",
      "paymentProofUrl": proofUrl,
      "status": "pending",
      "createdAt": Timestamp.now(),
    });

    await NotificationService().sendNotification(
      userId: "sales_manager_id_here",
      role: "sales_manager",
      title: "Payment Submitted",
      message: "Client submitted payment proof",
      type: "payment",
      referenceId: selectedInvoiceId!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Submitted Successfully")),
    );

    Navigator.pop(context);
    setState(() => loading = false);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make Payment"),
        backgroundColor: AppColors.darkBlue,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: loading ? null : submitPayment,
          child: loading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            "SUBMIT PAYMENT",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= INVOICE =================

            buildCard(
              title: "Invoice Selection",
              icon: Icons.receipt_long,
              child: buildInvoiceDropdown(),
            ),

            const SizedBox(height: 16),

            // ================= PAYMENT DETAILS =================

            buildCard(
              title: "Payment Details",
              icon: Icons.payment,
              child: Column(
                children: [

                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  buildPhaseDropdown(),

                  const SizedBox(height: 12),

                  buildModeDropdown(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= PAYMENT PROOF =================

            buildCard(
              title: "Payment Proof",
              icon: Icons.upload_file,
              child: Column(
                children: [

                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload Proof"),
                    onPressed: pickImage,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        proofFile == null
                            ? Icons.cancel
                            : Icons.check_circle,
                        color: proofFile == null
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        proofFile == null
                            ? "No file selected"
                            : "Proof uploaded",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= REUSABLE UI =================

  Widget buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(icon, color: AppColors.darkBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const Divider(),

          child,
        ],
      ),
    );
  }

  // ================= DROPDOWNS =================

  Widget buildInvoiceDropdown() {
    return FutureBuilder(
      future: fetchInvoices(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final invoices = snapshot.data!;

        if (invoices.isEmpty) {
          return const Text("No unpaid invoices");
        }

        return DropdownButtonFormField(
          decoration: const InputDecoration(
            labelText: "Select Invoice",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          items: invoices.map((inv) {
            return DropdownMenuItem(
              value: inv.id,
              child: Text(inv['invoiceNumber']),
            );
          }).toList(),

          onChanged: (val) {
            selectedInvoiceId = val.toString();
          },
        );
      },
    );
  }

  Widget buildPhaseDropdown() {
    return DropdownButtonFormField(
      value: phase,
      decoration: const InputDecoration(
        labelText: "Payment Phase",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.timeline),
      ),
      items: const [
        DropdownMenuItem(value: "phase1", child: Text("Advance Payment")),
        DropdownMenuItem(value: "phase2", child: Text("Interim Payment")),
        DropdownMenuItem(value: "phase3", child: Text("Final Payment")),
      ],
      onChanged: (val) {
        setState(() => phase = val!);
      },
    );
  }

  Widget buildModeDropdown() {
    return DropdownButtonFormField(
      value: paymentMode,
      decoration: const InputDecoration(
        labelText: "Payment Mode",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.account_balance_wallet),
      ),
      items: const [
        DropdownMenuItem(value: "upi", child: Text("UPI")),
        DropdownMenuItem(value: "net_banking", child: Text("Net Banking")),
        DropdownMenuItem(value: "cash", child: Text("Cash")),
        DropdownMenuItem(value: "cheque", child: Text("Cheque")),
      ],
      onChanged: (val) {
        setState(() => paymentMode = val!);
      },
    );
  }
}
