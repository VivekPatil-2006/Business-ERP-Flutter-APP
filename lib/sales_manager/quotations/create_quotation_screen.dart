// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../core/services/notification_service.dart';
// import '../../core/theme/app_colors.dart';
//
// class CreateQuotationScreen extends StatefulWidget {
//   const CreateQuotationScreen({super.key});
//
//   @override
//   State<CreateQuotationScreen> createState() =>
//       _CreateQuotationScreenState();
// }
//
// class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
//
//   final firestore = FirebaseFirestore.instance;
//   final auth = FirebaseAuth.instance;
//
//   // ================= STATE =================
//
//   String? selectedEnquiryDropdown;
//
//   String? enquiryId;
//   String? productId;
//   String? productName;
//   String? clientId;
//
//   String enquiryTitle = "";
//   String enquiryDescription = "";
//
//   String companyId = "";
//
//   Map<String, dynamic>? selectedProductData;
//
//   int enquiryQuantity = 1;
//
//   final baseCtrl = TextEditingController();
//   final discountCtrl = TextEditingController(text: "0");
//   final extraDiscountCtrl = TextEditingController(text: "0");
//   final cgstCtrl = TextEditingController(text: "0");
//   final sgstCtrl = TextEditingController(text: "0");
//
//   double finalAmount = 0;
//
//   bool sending = false;
//   bool loadingProduct = false;
//   bool pageLoading = true;
//
//   // ================= INIT =================
//
//   @override
//   void initState() {
//     super.initState();
//     loadCompanyId();
//   }
//
//   Future<void> loadCompanyId() async {
//
//     final uid = auth.currentUser!.uid;
//
//     final snap = await firestore
//         .collection("sales_managers")
//         .doc(uid)
//         .get();
//
//     companyId = snap.data()?['companyId'] ?? "";
//
//     if (mounted) {
//       setState(() => pageLoading = false);
//     }
//   }
//
//   void showMsg(String msg) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   // ================= FETCH ENQUIRIES =================
//
//   Future<List<QueryDocumentSnapshot>> fetchEnquiries() async {
//
//     final snap = await firestore
//         .collection("enquiries")
//         .where("companyId", isEqualTo: companyId)
//         .where("status", isEqualTo: "raised")
//         .get();
//
//     return snap.docs;
//   }
//
//   // ================= FETCH PRODUCT =================
//
//   Future<void> fetchProductDetails(String productId) async {
//
//     final snap = await firestore
//         .collection("products")
//         .doc(productId)
//         .get();
//
//     if (!snap.exists) return;
//
//     final data = snap.data()!;
//
//     final basePrice =
//     (data['pricing']?['basePrice'] ?? 0).toDouble();
//
//     final discountPercent =
//     (data['discountPercent'] ?? 0).toDouble();
//
//     final cgstPercent =
//     (data['tax']?['cgst'] ?? 0).toDouble();
//
//     final sgstPercent =
//     (data['tax']?['sgst'] ?? 0).toDouble();
//
//     if (!mounted) return;
//
//     setState(() {
//
//       selectedProductData = data;
//       productName = data['title'] ?? "Product";
//
//       baseCtrl.text = basePrice.toStringAsFixed(0);
//       discountCtrl.text = discountPercent.toStringAsFixed(0);
//
//       cgstCtrl.text = cgstPercent.toStringAsFixed(0);
//       sgstCtrl.text = sgstPercent.toStringAsFixed(0);
//     });
//
//     calculateFinal();
//   }
//
//   // ================= CALCULATION =================
//
//   void calculateFinal() {
//
//     double base = double.tryParse(baseCtrl.text) ?? 0;
//     double discount = double.tryParse(discountCtrl.text) ?? 0;
//     double extraDiscount = double.tryParse(extraDiscountCtrl.text) ?? 0;
//     double cgst = double.tryParse(cgstCtrl.text) ?? 0;
//     double sgst = double.tryParse(sgstCtrl.text) ?? 0;
//
//     discount = discount.clamp(0, 100);
//     extraDiscount = extraDiscount.clamp(0, 100);
//
//     final totalBase = base * enquiryQuantity;
//
//     final discountAmt = totalBase * discount / 100;
//     final afterDiscount = totalBase - discountAmt;
//
//     final extraDiscountAmt =
//         afterDiscount * extraDiscount / 100;
//
//     final afterExtraDiscount =
//         afterDiscount - extraDiscountAmt;
//
//     final cgstAmt = afterExtraDiscount * cgst / 100;
//     final sgstAmt = afterExtraDiscount * sgst / 100;
//
//     if (mounted) {
//       setState(() {
//         finalAmount = afterExtraDiscount + cgstAmt + sgstAmt;
//       });
//     }
//   }
//
//   // ================= SAVE =================
//
//   Future<void> saveQuotation() async {
//
//     if (enquiryId == null ||
//         clientId == null ||
//         productId == null) {
//
//       showMsg("Please select enquiry");
//       return;
//     }
//
//     if (finalAmount <= 0) {
//       showMsg("Invalid quotation amount");
//       return;
//     }
//
//     try {
//
//       setState(() => sending = true);
//
//       final userId = auth.currentUser!.uid;
//
//       final docRef =
//       await firestore.collection("quotations").add({
//
//         "enquiryId": enquiryId,
//         "productId": productId,
//         "clientId": clientId,
//
//         "companyId": companyId,
//         "salesManagerId": userId,
//
//         "productSnapshot": {
//
//           "productId": productId,
//           "productName": productName,
//           "quantity": enquiryQuantity,
//
//           "basePrice": double.tryParse(baseCtrl.text) ?? 0,
//           "discountPercent": double.tryParse(discountCtrl.text) ?? 0,
//           "extraDiscountPercent":
//           double.tryParse(extraDiscountCtrl.text) ?? 0,
//
//           "cgstPercent": double.tryParse(cgstCtrl.text) ?? 0,
//           "sgstPercent": double.tryParse(sgstCtrl.text) ?? 0,
//
//           "finalAmount": finalAmount,
//         },
//
//         "quotationAmount": finalAmount,
//         "status": "sent",
//         "pdfUrl": "",
//
//         "createdAt": Timestamp.now(),
//         "updatedAt": Timestamp.now(),
//       });
//
//       await firestore
//           .collection("enquiries")
//           .doc(enquiryId)
//           .update({"status": "quoted"});
//
//       await NotificationService().sendNotification(
//
//         userId: clientId!,
//         role: "client",
//
//         title: "New Quotation Received",
//         message: "Sales manager sent you a quotation",
//
//         type: "quotation",
//         referenceId: docRef.id,
//       );
//
//       showMsg("Quotation Sent Successfully");
//
//       Navigator.pop(context);
//
//     } catch (e) {
//
//       debugPrint("Quotation Error => $e");
//       showMsg("Error sending quotation");
//
//     } finally {
//
//       if (mounted) {
//         setState(() => sending = false);
//       }
//     }
//   }
//
//   // ================= UI =================
//
//   @override
//   Widget build(BuildContext context) {
//
//     if (pageLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text(
//           "Create Quotation",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColors.darkBlue,
//         foregroundColor: Colors.white,
//       ),
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//
//               // ================= SELECT ENQUIRY =================
//
//               buildSectionCard(
//                 title: "Select Enquiry",
//
//                 child: FutureBuilder(
//                   future: fetchEnquiries(),
//
//                   builder: (context, snapshot) {
//
//                     if (!snapshot.hasData) {
//                       return const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 8),
//                         child: LinearProgressIndicator(),
//                       );
//                     }
//
//                     final enquiries = snapshot.data!;
//
//                     if (enquiries.isEmpty) {
//                       return const Text("No pending enquiries");
//                     }
//
//                     return DropdownButtonFormField<String>(
//
//                       value: selectedEnquiryDropdown,
//
//                       isExpanded: true, // ✅ IMPORTANT (fixes overflow)
//
//                       decoration: const InputDecoration(
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.assignment),
//                       ),
//
//                       hint: const Text("Choose Enquiry"),
//
//                       items: enquiries.map((e) {
//
//                         final title = e['title'] ?? "Enquiry";
//
//                         return DropdownMenuItem<String>(
//                           value: e.id,
//
//                           child: Text(
//                             title,
//                             maxLines: 1,                 // ✅ limit lines
//                             overflow: TextOverflow.ellipsis, // ✅ add ...
//                             softWrap: false,
//                           ),
//                         );
//
//                       }).toList(),
//
//                       onChanged: (val) async {
//
//                         final e =
//                         enquiries.firstWhere((x) => x.id == val);
//
//                         setState(() {
//
//                           selectedEnquiryDropdown = val;
//                           enquiryId = val;
//
//                           final data =
//                           e.data() as Map<String, dynamic>;
//
//                           productId = data['productId'];
//                           clientId = data['clientId'];
//
//                           enquiryTitle = data['title'] ?? "";
//                           enquiryDescription = data['description'] ?? "";
//
//                           enquiryQuantity = data['quantity'] ?? 1;
//
//                           loadingProduct = true;
//                           selectedProductData = null;
//                         });
//
//                         if (productId != null) {
//                           await fetchProductDetails(productId!);
//                         }
//
//                         if (mounted) {
//                           setState(() => loadingProduct = false);
//                         }
//                       },
//                     );
//                   },
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // ================= ENQUIRY DETAILS =================
//
//               if (enquiryId != null)
//
//                 buildSectionCard(
//                   title: "Enquiry Details",
//
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       Text(
//                         "Title: $enquiryTitle",
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//
//                       infoRow("Quantity", enquiryQuantity.toString()),
//
//                       const SizedBox(height: 6),
//
//                       Text(
//                         "Description: $enquiryDescription",
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//
//               const SizedBox(height: 16),
//
//               // ================= PRODUCT DETAILS =================
//
//               if (loadingProduct)
//                 const LinearProgressIndicator(),
//
//               if (selectedProductData != null)
//
//                 buildSectionCard(
//                   title: "Product Details",
//                   child: buildProductPreview(selectedProductData!),
//                 ),
//
//               const SizedBox(height: 20),
//
//               // ================= PRICING =================
//
//               buildSectionCard(
//                 title: "Pricing Details",
//
//                 child: Column(
//                   children: [
//
//                     buildInput(baseCtrl, "Base Amount", Icons.currency_rupee),
//                     const SizedBox(height: 10),
//
//                     buildInput(discountCtrl, "Product Discount %", Icons.percent),
//                     const SizedBox(height: 10),
//
//                     buildInput(extraDiscountCtrl, "Extra Discount %", Icons.trending_down),
//                     const SizedBox(height: 10),
//
//                     buildInput(cgstCtrl, "CGST %", Icons.account_balance),
//                     const SizedBox(height: 10),
//
//                     buildInput(sgstCtrl, "SGST %", Icons.account_balance),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // ================= FINAL AMOUNT =================
//
//               Container(
//                 padding: const EdgeInsets.all(16),
//
//                 decoration: BoxDecoration(
//                   color: AppColors.cardWhite,
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(color: Colors.green.withOpacity(0.3)),
//                 ),
//
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//
//                     const Text(
//                       "Final Amount",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//
//                     Text(
//                       "₹ ${finalAmount.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 28),
//
//               // ================= SEND BUTTON =================
//
//               SizedBox(
//                 width: double.infinity,
//
//                 child: ElevatedButton.icon(
//
//                   icon: sending
//                       ? const SizedBox(
//                     height: 18,
//                     width: 18,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                       : const Icon(Icons.send, color: Colors.white),
//
//                   label: const Text(
//                     "SEND QUOTATION",
//                     style: TextStyle(color: Colors.white),
//                   ),
//
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.darkBlue,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//
//                   onPressed: sending ? null : saveQuotation,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ================= PRODUCT UI =================
//
//   Widget buildProductPreview(Map<String, dynamic> p) {
//
//     final pricing = p['pricing'] ?? {};
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//
//         infoRow("Product", p['title'] ?? "-"),
//         infoRow("Item No", p['itemNo'] ?? "-"),
//         infoRow("Base Price", "₹ ${pricing['basePrice'] ?? '-'}"),
//         infoRow("Stock", p['stock']?.toString() ?? "-"),
//         infoRow("Size", p['size'] ?? "-"),
//       ],
//     );
//   }
//
//   Widget infoRow(String label, String value) {
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//
//       child: Row(
//         children: [
//
//           SizedBox(
//             width: 130,
//             child: Text(
//               "$label:",
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
//
//   // ================= COMMON UI =================
//
//   Widget buildSectionCard({
//     required String title,
//     required Widget child,
//   }) {
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//
//       decoration: BoxDecoration(
//         color: AppColors.cardWhite,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//           ),
//         ],
//       ),
//
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 15,
//             ),
//           ),
//
//           const SizedBox(height: 10),
//
//           child,
//         ],
//       ),
//     );
//   }
//
//   Widget buildInput(
//       TextEditingController controller,
//       String label,
//       IconData icon,
//       ) {
//
//     return TextField(
//       controller: controller,
//       keyboardType: TextInputType.number,
//       enabled: !loadingProduct,
//
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: const OutlineInputBorder(),
//       ),
//
//       onChanged: (_) => calculateFinal(),
//     );
//   }
//
//   @override
//   void dispose() {
//
//     baseCtrl.dispose();
//     discountCtrl.dispose();
//     extraDiscountCtrl.dispose();
//     cgstCtrl.dispose();
//     sgstCtrl.dispose();
//
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../../../services/api_service.dart';
import 'services/quotation_service.dart';

class CreateQuotationScreen extends StatefulWidget {
  const CreateQuotationScreen({super.key});

  @override
  State<CreateQuotationScreen> createState() =>
      _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  // ================= STATE =================

  String? selectedEnquiryId;
  Map<String, dynamic>? selectedEnquiry;

  final baseCtrl = TextEditingController();
  final discountCtrl = TextEditingController(text: "0");
  final extraDiscountCtrl = TextEditingController(text: "0");
  final cgstCtrl = TextEditingController(text: "0");
  final sgstCtrl = TextEditingController(text: "0");

  bool sending = false;
  bool loading = false;

  // ================= FETCH ENQUIRIES =================

  Future<List<Map<String, dynamic>>> fetchEnquiries() async {
    final res = await ApiService.get('/enquiries');
    final list = List<Map<String, dynamic>>.from(res['enquiries'] ?? []);
    return list.where((e) => e['status'] == 'raised').toList();
  }

  // ================= FETCH PRODUCT =================

  Future<void> loadProductDefaults(String productId) async {
    setState(() => loading = true);

    final res = await ApiService.get('/products/$productId');
    final p = res['product'];

    final pricing = p['pricing'] ?? {};
    final tax = p['tax'] ?? {};

    baseCtrl.text = (pricing['basePrice'] ?? 0).toString();
    discountCtrl.text = (p['discountPercent'] ?? 0).toString();
    cgstCtrl.text = (tax['cgst'] ?? 0).toString();
    sgstCtrl.text = (tax['sgst'] ?? 0).toString();

    setState(() => loading = false);
  }

  // ================= SAVE QUOTATION =================

  Future<void> saveQuotation() async {
    if (selectedEnquiry == null) {
      showMsg("Select enquiry");
      return;
    }

    try {
      setState(() => sending = true);

      await QuotationService().createQuotation(
        enquiryId: selectedEnquiry!['enquiryId'],
        baseAmount: double.parse(baseCtrl.text),
        discountPercent: double.parse(discountCtrl.text),
        extraDiscount: double.parse(extraDiscountCtrl.text),
        cgstPercent: double.parse(cgstCtrl.text),
        sgstPercent: double.parse(sgstCtrl.text),
        quantity: selectedEnquiry!['quantity'] ?? 1,
      );

      showMsg("Quotation created successfully");
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Create Quotation Error => $e");
      showMsg("Failed to create quotation");
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Quotation",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= ENQUIRY =================

            buildCard(
              title: "Select Enquiry",
              icon: Icons.assignment,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchEnquiries(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final enquiries = snapshot.data!;
                  if (enquiries.isEmpty) {
                    return const Text("No pending enquiries");
                  }

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.assignment),
                    ),
                    hint: const Text("Choose Enquiry"),
                    value: selectedEnquiryId,
                    items: enquiries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e['enquiryId'],
                        child: Text(
                          e['title'] ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      final e =
                      enquiries.firstWhere((x) => x['enquiryId'] == val);
                      setState(() {
                        selectedEnquiryId = val;
                        selectedEnquiry = e;
                      });
                      await loadProductDefaults(e['productId']);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ================= ENQUIRY DETAILS =================

            if (selectedEnquiry != null)
              buildCard(
                title: "Enquiry Details",
                icon: Icons.info,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoRow("Title", selectedEnquiry!['title']),
                    infoRow("Quantity",
                        (selectedEnquiry!['quantity'] ?? 1).toString()),
                    infoRow("Source", selectedEnquiry!['source'] ?? "-"),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ================= PRICING =================

            buildCard(
              title: "Pricing",
              icon: Icons.currency_rupee,
              child: Column(
                children: [
                  buildInput(baseCtrl, "Base Amount"),
                  buildInput(discountCtrl, "Discount %"),
                  buildInput(extraDiscountCtrl, "Extra Discount"),
                  buildInput(cgstCtrl, "CGST %"),
                  buildInput(sgstCtrl, "SGST %"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= SUBMIT =================

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }

  Widget buildInput(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text("$label:",
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    baseCtrl.dispose();
    discountCtrl.dispose();
    extraDiscountCtrl.dispose();
    cgstCtrl.dispose();
    sgstCtrl.dispose();
    super.dispose();
  }
}
