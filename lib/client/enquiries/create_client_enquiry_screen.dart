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
  Map<String, dynamic>? selectedProductData;

  // ✅ Source of enquiry
  String? selectedSource;

  final List<String> enquirySources = [
    "Email",
    "Phone",
    "Walk-in",
    "Reference",
    "Other",
  ];

  bool loading = false;
  bool pageLoading = true;

  // ================= LOAD COMPANY =================

  @override
  void initState() {
    super.initState();
    loadClientCompany();
  }

  Future<void> loadClientCompany() async {

    final uid = auth.currentUser!.uid;

    final snap =
    await firestore.collection("clients").doc(uid).get();

    companyId = snap.data()?['companyId'] ?? "";

    setState(() => pageLoading = false);
  }

  // ================= FETCH PRODUCTS =================

  Future<List<QueryDocumentSnapshot>> fetchProducts() async {

    final snap = await firestore
        .collection("products")
        .where("companyId", isEqualTo: companyId)
        .get();

    return snap.docs;
  }

  // ================= CREATE ENQUIRY =================

  Future<void> createEnquiry() async {

    if (selectedProductId == null) {
      showMsg("Select product");
      return;
    }

    if (selectedSource == null) {
      showMsg("Select enquiry source");
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

        // ✅ NEW FIELD
        "source": selectedSource,

        "status": "raised",
        "createdAt": Timestamp.now(),
      });

      await NotificationService().sendNotification(
        userId: "admin",
        role: "sales_manager",
        title: "New Client Enquiry",
        message: "Client submitted new enquiry",
        type: "enquiry",
        referenceId: docRef.id,
      );

      showMsg("Enquiry Submitted Successfully");

      titleCtrl.clear();
      descCtrl.clear();

      setState(() {
        selectedProductId = null;
        selectedProductData = null;
        selectedSource = null;
      });

    } catch (e) {

      debugPrint("Create Enquiry Error => $e");
      showMsg("Failed to submit enquiry");

    } finally {
      setState(() => loading = false);
    }
  }

  // ================= UI =================

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

              FutureBuilder<List<QueryDocumentSnapshot>>(
                future: fetchProducts(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final products = snapshot.data!;

                  return DropdownButtonFormField<String>(
                    value: selectedProductId,

                    decoration: InputDecoration(
                      labelText: "Select Product",
                      prefixIcon: const Icon(Icons.shopping_bag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    items: products.map((p) {

                      final data = p.data() as Map<String, dynamic>;

                      return DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(data['title'] ?? "Product"),
                      );

                    }).toList(),

                    onChanged: (String? val) async {

                      if (val == null) return;

                      setState(() {
                        selectedProductId = val;
                        selectedProductData = null;
                      });

                      final snap =
                      await firestore.collection("products").doc(val).get();

                      if (snap.exists) {
                        setState(() {
                          selectedProductData = snap.data();
                        });
                      }
                    },
                  );
                },
              ),

              // ================= PRODUCT PREVIEW =================

              if (selectedProductData != null) ...[

                const SizedBox(height: 12),

                buildProductPreview(selectedProductData!),
              ],

              // ================= ENQUIRY SOURCE =================

              if (selectedProductId != null) ...[

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: selectedSource,

                  decoration: InputDecoration(
                    labelText: "Source Of Enquiry",
                    prefixIcon: const Icon(Icons.source),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  items: enquirySources.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),

                  onChanged: (val) {
                    setState(() => selectedSource = val);
                  },
                ),

                const SizedBox(height: 14),

                buildInput(
                  controller: titleCtrl,
                  label: "Enquiry Title",
                  icon: Icons.title,
                ),

                const SizedBox(height: 12),

                buildInput(
                  controller: descCtrl,
                  label: "Enquiry Description",
                  icon: Icons.description,
                  maxLines: 4,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================= PRODUCT CARD =================

  Widget buildProductPreview(Map<String, dynamic> p) {

    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            p['title'] ?? "Product",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const Divider(),

          infoRow("Price", "₹ ${p['pricing']?['basePrice'] ?? '-'}"),
          infoRow("Stock", p['stock']?.toString() ?? "-"),
          infoRow("Size", p['size'] ?? "-"),

          if (p['description'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(p['description']),
            ),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

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
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const Divider(),

          child,
        ],
      ),
    );
  }

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

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }
}
