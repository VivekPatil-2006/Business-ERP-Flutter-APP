import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';


class CreateEnquiryScreen extends StatefulWidget {
  const CreateEnquiryScreen({super.key});

  @override
  State<CreateEnquiryScreen> createState() => _CreateEnquiryScreenState();
}

class _CreateEnquiryScreenState extends State<CreateEnquiryScreen> {

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String? selectedClientId;
  String? selectedProductId;
  String companyId = "";

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  bool loading = false;

  // ============================
  // INIT
  // ============================

  @override
  void initState() {
    super.initState();
    loadCompanyId();
  }

  Future<void> loadCompanyId() async {

    final uid = auth.currentUser!.uid;

    final snap = await firestore
        .collection("sales_managers")
        .doc(uid)
        .get();

    setState(() {
      companyId = snap.data()?['companyId'] ?? "";
    });
  }

  // ============================
  // FETCH CLIENTS
  // ============================

  Future<List<QueryDocumentSnapshot>> fetchClients() async {

    final snap = await firestore
        .collection("clients")
        .where("companyId", isEqualTo: companyId)
        .get();

    return snap.docs;
  }

  // ============================
  // FETCH PRODUCTS
  // ============================

  Future<List<QueryDocumentSnapshot>> fetchProducts() async {

    final snap = await firestore
        .collection("products")
        .get();

    return snap.docs;
  }

  // ============================
  // CREATE ENQUIRY
  // ============================

  Future<void> createEnquiry() async {

    if (selectedClientId == null) {
      showMsg("Select client");
      return;
    }

    if (selectedProductId == null) {
      showMsg("Select product");
      return;
    }

    if (titleCtrl.text.trim().isEmpty) {
      showMsg("Enter enquiry title");
      return;
    }

    try {

      setState(() => loading = true);

      await firestore.collection("enquiries").add({

        "companyId": companyId,

        "clientId": selectedClientId,
        "salesManagerId": auth.currentUser!.uid,

        "productId": selectedProductId,

        "title": titleCtrl.text.trim(),
        "description": descCtrl.text.trim(),

        "status": "raised",
        "createdAt": Timestamp.now(),
      });

      showMsg("Enquiry Created Successfully");
      Navigator.pop(context);

    } catch (e) {

      showMsg("Failed to create enquiry");

    } finally {

      setState(() => loading = false);
    }
  }

  // ============================
  // SNACKBAR
  // ============================

  void showMsg(String msg) {

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================
  // UI
  // ============================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Create Enquiry"),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
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
            "CREATE ENQUIRY",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white, // <- set text color explicitly
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // ================= CLIENT =================

            buildCard(
              title: "Client Selection",
              icon: Icons.people,
              child: FutureBuilder(
                future: fetchClients(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final clients = snapshot.data!;

                  if (clients.isEmpty) {
                    return const Text("No clients found");
                  }

                  return DropdownButtonFormField(
                    hint: const Text("Choose Client"),

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),

                    items: clients.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c['companyName']),
                      );
                    }).toList(),

                    onChanged: (val) {
                      selectedClientId = val.toString();
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ================= PRODUCT =================

            buildCard(
              title: "Product Selection",
              icon: Icons.inventory,
              child: FutureBuilder(
                future: fetchProducts(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final products = snapshot.data!;

                  return DropdownButtonFormField(
                    hint: const Text("Choose Product"),

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.shopping_bag),
                    ),

                    items: products.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(p['title']),
                      );
                    }).toList(),

                    onChanged: (val) {
                      selectedProductId = val.toString();
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ================= ENQUIRY DETAILS =================

            buildCard(
              title: "Enquiry Details",
              icon: Icons.assignment,
              child: Column(
                children: [

                  buildInput(
                    controller: titleCtrl,
                    label: "Enquiry Title",
                    icon: Icons.title,
                  ),

                  const SizedBox(height: 12),

                  buildInput(
                    controller: descCtrl,
                    label: "Description",
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // CARD UI
  // ============================

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

  // ============================
  // INPUT
  // ============================

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

  // ============================
  // DISPOSE
  // ============================

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }
}
