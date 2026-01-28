import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';

class CreateQuotationScreen extends StatefulWidget {
  const CreateQuotationScreen({super.key});

  @override
  State<CreateQuotationScreen> createState() =>
      _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  // ================= STATE =================

  String? selectedEnquiryDropdown;

  String? enquiryId;
  String? productId;
  String? productName;
  String? clientId;

  String enquiryTitle = "";
  String enquiryDescription = "";

  final baseCtrl = TextEditingController();
  final discountCtrl = TextEditingController(text: "0");
  final cgstCtrl = TextEditingController(text: "0");
  final sgstCtrl = TextEditingController(text: "0");

  double finalAmount = 0;

  bool sending = false;
  bool loadingProduct = false;

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ================= FETCH ENQUIRIES =================

  Future<List<QueryDocumentSnapshot>> fetchEnquiries() async {

    final snap = await firestore
        .collection("enquiries")
        .where("status", isEqualTo: "raised")
        .get();

    return snap.docs;
  }

  // ================= FETCH PRODUCT DETAILS =================

  Future<void> fetchProductDetails(String productId) async {

    final snap = await firestore
        .collection("products")
        .doc(productId)
        .get();

    if (!snap.exists) return;

    final data = snap.data()!;

    final basePrice =
    (data['pricing']?['basePrice'] ?? 0).toDouble();

    final discountPercent =
    (data['discountPercent'] ?? 0).toDouble();

    setState(() {

      productName = data['title'] ?? "Product";

      // ✅ Auto fill base price
      baseCtrl.text = basePrice.toStringAsFixed(0);

      // ✅ Auto fill product discount
      discountCtrl.text = discountPercent.toStringAsFixed(0);
    });

    calculateFinal();
  }

  // ================= CALCULATE FINAL =================

  void calculateFinal() {

    final base = double.tryParse(baseCtrl.text) ?? 0;
    final discount = double.tryParse(discountCtrl.text) ?? 0;
    final cgst = double.tryParse(cgstCtrl.text) ?? 0;
    final sgst = double.tryParse(sgstCtrl.text) ?? 0;

    final discountAmt = base * discount / 100;
    final afterDiscount = base - discountAmt;

    final cgstAmt = afterDiscount * cgst / 100;
    final sgstAmt = afterDiscount * sgst / 100;

    setState(() {
      finalAmount = afterDiscount + cgstAmt + sgstAmt;
    });
  }

  // ================= SAVE QUOTATION =================

  Future<void> saveQuotation() async {

    if (enquiryId == null || clientId == null) {
      showMsg("Please select enquiry");
      return;
    }

    if (finalAmount <= 0) {
      showMsg("Invalid quotation amount");
      return;
    }

    try {

      setState(() => sending = true);

      final userId = auth.currentUser!.uid;

      final docRef =
      await firestore.collection("quotations").add({

        "enquiryId": enquiryId,
        "clientId": clientId,
        "salesManagerId": userId,

        // ================= SNAPSHOT =================

        "productSnapshot": {

          "productId": productId,
          "productName": productName,

          "basePrice": double.parse(baseCtrl.text),
          "discountPercent": double.parse(discountCtrl.text),
          "cgstPercent": double.parse(cgstCtrl.text),
          "sgstPercent": double.parse(sgstCtrl.text),

          "finalAmount": finalAmount,
        },

        "quotationAmount": finalAmount,

        "status": "sent",

        "pdfUrl": "",
        "createdAt": Timestamp.now(),
        "updatedAt": Timestamp.now(),
      });

      // Update enquiry status
      await firestore
          .collection("enquiries")
          .doc(enquiryId)
          .update({"status": "quoted"});

      // Notify client
      await NotificationService().sendNotification(
        userId: clientId!,
        role: "client",
        title: "New Quotation Received",
        message: "Sales manager sent you a quotation",
        type: "quotation",
        referenceId: docRef.id,
      );

      showMsg("Quotation Sent Successfully");

      Navigator.pop(context);

    } catch (e) {

      debugPrint("Quotation Error => $e");
      showMsg("Error sending quotation");

    } finally {

      setState(() => sending = false);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Create Quotation"),
        backgroundColor: AppColors.darkBlue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= SELECT ENQUIRY =================

            buildSectionCard(
              title: "Select Enquiry",

              child: FutureBuilder(
                future: fetchEnquiries(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final enquiries = snapshot.data!;

                  return DropdownButtonFormField<String>(

                    value: selectedEnquiryDropdown,

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.assignment),
                    ),

                    hint: const Text("Choose Enquiry"),

                    items: enquiries.map((e) {

                      return DropdownMenuItem<String>(
                        value: e.id,
                        child: Text(e['title']),
                      );

                    }).toList(),

                    onChanged: (val) {

                      final e =
                      enquiries.firstWhere((x) => x.id == val);

                      setState(() {

                        loadingProduct = true;

                        selectedEnquiryDropdown = val;

                        enquiryId = val;
                        productId = e['productId'];
                        clientId = e['clientId'];

                        enquiryTitle = e['title'];
                        enquiryDescription = e['description'];

                        productName = null;
                      });

                      fetchProductDetails(productId!).then((_) {

                        if (!mounted) return;

                        setState(() => loadingProduct = false);
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ================= ENQUIRY DETAILS =================

            if (enquiryId != null)

              buildSectionCard(
                title: "Enquiry Details",

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text("Title: $enquiryTitle"),

                    const SizedBox(height: 6),

                    loadingProduct
                        ? const LinearProgressIndicator()
                        : Text("Product: $productName"),

                    const SizedBox(height: 6),

                    Text("Description: $enquiryDescription"),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ================= PRICING =================

            buildSectionCard(
              title: "Pricing Details",

              child: Column(
                children: [

                  buildInput(
                    controller: baseCtrl,
                    label: "Base Amount",
                    icon: Icons.currency_rupee,
                  ),

                  const SizedBox(height: 10),

                  buildInput(
                    controller: discountCtrl,
                    label: "Discount %",
                    icon: Icons.percent,
                  ),

                  const SizedBox(height: 10),

                  buildInput(
                    controller: cgstCtrl,
                    label: "CGST %",
                    icon: Icons.account_balance,
                  ),

                  const SizedBox(height: 10),

                  buildInput(
                    controller: sgstCtrl,
                    label: "SGST %",
                    icon: Icons.account_balance,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= TOTAL =================

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(14),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Text(
                    "Final Amount",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "₹ ${finalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= SEND =================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(

                icon: sending
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send, color: Colors.white),

                label: const Text(
                  "SEND QUOTATION",
                  style: TextStyle(color: Colors.white),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                onPressed: sending ? null : saveQuotation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget buildSectionCard({
    required String title,
    required Widget child,
  }) {

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),

      onChanged: (_) => calculateFinal(),
    );
  }

  @override
  void dispose() {

    baseCtrl.dispose();
    discountCtrl.dispose();
    cgstCtrl.dispose();
    sgstCtrl.dispose();

    super.dispose();
  }
}
