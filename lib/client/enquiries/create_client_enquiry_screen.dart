import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';

class CreateClientEnquiryScreen extends StatefulWidget {
  const CreateClientEnquiryScreen({super.key});

  @override
  State<CreateClientEnquiryScreen> createState() =>
      _CreateClientEnquiryScreenState();
}

class _CreateClientEnquiryScreenState
    extends State<CreateClientEnquiryScreen> {

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String companyId = "";
  String? selectedProductId;

  bool loading = false;
  bool pageLoading = true;

  // ==========================
  // LOAD CLIENT COMPANY
  // ==========================

  Future<void> loadClientCompany() async {

    final uid = auth.currentUser!.uid;

    final snap = await firestore
        .collection("clients")
        .doc(uid)
        .get();

    companyId = snap.data()?['companyId'] ?? "";

    setState(() => pageLoading = false);
  }

  @override
  void initState() {
    super.initState();
    loadClientCompany();
  }

  // ==========================
  // FETCH PRODUCTS BY COMPANY
  // ==========================

  Future<List<QueryDocumentSnapshot>> fetchProducts() async {

    final snap = await firestore
        .collection("products")
        .where("companyId", isEqualTo: companyId)
        .get();

    return snap.docs;
  }

  // ==========================
  // CREATE ENQUIRY
  // ==========================

  Future<void> createEnquiry() async {

    if (selectedProductId == null) {
      showMsg("Select product");
      return;
    }

    if (titleCtrl.text.trim().isEmpty) {
      showMsg("Enter enquiry title");
      return;
    }

    if (descCtrl.text.trim().isEmpty) {
      showMsg("Enter enquiry description");
      return;
    }

    try {

      setState(() => loading = true);

      final clientId = auth.currentUser!.uid;

      final docRef =
      await firestore.collection("enquiries").add({

        "title": titleCtrl.text.trim(),
        "description": descCtrl.text.trim(),

        "companyId": companyId,
        "clientId": clientId,
        "salesManagerId": "",

        "productId": selectedProductId,

        "status": "raised",
        "createdAt": Timestamp.now(),
      });

      // Notify Sales Manager / Admin
      await NotificationService().sendNotification(
        userId: "admin",
        role: "sales_manager",
        title: "New Client Enquiry",
        message: "A client submitted a new enquiry",
        type: "enquiry",
        referenceId: docRef.id,
      );

      showMsg("Enquiry Submitted Successfully");

      titleCtrl.clear();
      descCtrl.clear();
      selectedProductId = null;

    } catch (e) {

      showMsg("Failed to submit enquiry");

    } finally {

      setState(() => loading = false);
    }
  }

  // ==========================
  // SNACKBAR
  // ==========================

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ==========================
  // UI
  // ==========================

  @override
  Widget build(BuildContext context) {

    if (pageLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Create Enquiry"),
        backgroundColor: AppColors.darkBlue,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),

        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),

          onPressed: loading ? null : createEnquiry,

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
            "SUBMIT ENQUIRY",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: buildCard(
          title: "Enquiry Details",
          icon: Icons.assignment,

          child: Column(
            children: [

              // ================= PRODUCT DROPDOWN =================

              FutureBuilder(
                future: fetchProducts(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final products = snapshot.data!;

                  if (products.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("No products available"),
                    );
                  }

                  return DropdownButtonFormField(
                    value: selectedProductId,

                    decoration: InputDecoration(
                      labelText: "Select Product",
                      prefixIcon: const Icon(Icons.shopping_bag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    items: products.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(p['title']),
                      );
                    }).toList(),

                    onChanged: (val) {
                      setState(() => selectedProductId = val);
                    },
                  );
                },
              ),

              const SizedBox(height: 14),

              // ================= TITLE =================

              buildInput(
                controller: titleCtrl,
                label: "Enquiry Title",
                icon: Icons.title,
              ),

              const SizedBox(height: 12),

              // ================= DESCRIPTION =================

              buildInput(
                controller: descCtrl,
                label: "Enquiry Description",
                icon: Icons.description,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================
  // CARD UI
  // ==========================

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

  // ==========================
  // INPUT FIELD
  // ==========================

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {

    return TextField(
      controller: controller,
      maxLines: maxLines,

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }
}
