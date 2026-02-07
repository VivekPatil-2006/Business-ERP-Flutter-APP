// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// import '../../core/services/notification_service.dart';
// import '../../core/theme/app_colors.dart';
//
// class CreateClientEnquiryScreen extends StatefulWidget {
//   const CreateClientEnquiryScreen({super.key});
//
//   @override
//   State<CreateClientEnquiryScreen> createState() =>
//       _CreateClientEnquiryScreenState();
// }
//
// class _CreateClientEnquiryScreenState
//     extends State<CreateClientEnquiryScreen> {
//
//   final firestore = FirebaseFirestore.instance;
//   final auth = FirebaseAuth.instance;
//
//   final titleCtrl = TextEditingController();
//   final descCtrl = TextEditingController();
//   final qtyCtrl = TextEditingController(text: "1");
//
//   String companyId = "";
//   String salesManagerId = "";
//
//
//   String? selectedProductId;
//   Map<String, dynamic>? selectedProductData;
//
//   // ✅ Source
//   String? selectedSource;
//
//   final List<Map<String, String>> enquirySources = [
//     {"label": "By Walkin", "value": "by walkin"},
//     {"label": "By Email", "value": "by email"},
//     {"label": "By Phone", "value": "by phone"},
//     {"label": "By Reference", "value": "by reference"},
//     {"label": "Other", "value": "other"},
//   ];
//
//   // ✅ Expected Date
//   DateTime? expectedDate;
//
//   bool loading = false;
//   bool pageLoading = true;
//
//   // ================= LOAD COMPANY =================
//
//   @override
//   void initState() {
//     super.initState();
//     loadClientCompany();
//   }
//
//   Future<void> loadClientCompany() async {
//
//     final uid = auth.currentUser!.uid;
//
//     final snap =
//     await firestore.collection("clients").doc(uid).get();
//
//     companyId = snap.data()?['companyId'] ?? "";
//
//     // ✅ NEW
//     salesManagerId = snap.data()?['salesManagerId'] ?? "";
//
//     setState(() => pageLoading = false);
//   }
//
//   // ================= FETCH PRODUCTS =================
//
//   Future<List<QueryDocumentSnapshot>> fetchProducts() async {
//
//     final snap = await firestore
//         .collection("products")
//         .where("companyId", isEqualTo: companyId)
//         .where("active", isEqualTo: true)
//         .get();
//
//     return snap.docs;
//   }
//
//   // ================= DATE PICKER =================
//
//   Future<void> pickExpectedDate() async {
//
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//
//     if (picked != null) {
//       setState(() => expectedDate = picked);
//     }
//   }
//
//   // ================= CREATE ENQUIRY =================
//
//   Future<void> createEnquiry() async {
//
//     if (selectedProductId == null) {
//       showMsg("Select product");
//       return;
//     }
//
//     if (selectedSource == null) {
//       showMsg("Select enquiry source");
//       return;
//     }
//
//     if (expectedDate == null) {
//       showMsg("Select expected date");
//       return;
//     }
//
//     if (titleCtrl.text.trim().isEmpty) {
//       showMsg("Enter enquiry title");
//       return;
//     }
//
//     if (descCtrl.text.trim().isEmpty) {
//       showMsg("Enter enquiry description");
//       return;
//     }
//
//     final qty = int.tryParse(qtyCtrl.text) ?? 0;
//
//     if (qty <= 0) {
//       showMsg("Enter valid quantity");
//       return;
//     }
//
//     try {
//
//       setState(() => loading = true);
//
//       final clientId = auth.currentUser!.uid;
//
//       final docRef =
//       await firestore.collection("enquiries").add({
//
//         "title": titleCtrl.text.trim(),
//         "description": descCtrl.text.trim(),
//
//         "companyId": companyId,
//         "clientId": clientId,
//         "salesManagerId": salesManagerId,
//
//
//         "productId": selectedProductId,
//         "quantity": qty,
//
//         "productSnapshot": selectedProductData,
//
//         // ✅ normalized source
//         "source": selectedSource,
//
//         // ✅ expected date
//         "expectedDate": Timestamp.fromDate(expectedDate!),
//
//         "status": "raised",
//         "createdAt": Timestamp.now(),
//       });
//
//       await NotificationService().sendNotification(
//         userId: salesManagerId,
//         role: "sales_manager",
//         title: "New Client Enquiry",
//         message: "Client submitted new enquiry",
//         type: "enquiry",
//         referenceId: docRef.id,
//       );
//
//       showMsg("Enquiry Submitted Successfully");
//
//       titleCtrl.clear();
//       descCtrl.clear();
//       qtyCtrl.text = "1";
//
//       setState(() {
//         selectedProductId = null;
//         selectedProductData = null;
//         selectedSource = null;
//         expectedDate = null;
//       });
//
//     } catch (e) {
//
//       debugPrint("Create Enquiry Error => $e");
//       showMsg("Failed to submit enquiry");
//
//     } finally {
//       setState(() => loading = false);
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
//         title: const Text("Create Enquiry"),
//         backgroundColor: AppColors.darkBlue,
//       ),
//
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(12),
//
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.darkBlue,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//           ),
//
//           onPressed: loading ? null : createEnquiry,
//
//           child: loading
//               ? const SizedBox(
//             height: 20,
//             width: 20,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               color: Colors.white,
//             ),
//           )
//               : const Text(
//             "SUBMIT ENQUIRY",
//             style: TextStyle(fontSize: 16, color: Colors.white),
//           ),
//         ),
//       ),
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//
//         child: buildCard(
//           title: "Enquiry Details",
//           icon: Icons.assignment,
//
//           child: Column(
//             children: [
//
//               // ================= PRODUCT =================
//
//               FutureBuilder<List<QueryDocumentSnapshot>>(
//                 future: fetchProducts(),
//
//                 builder: (context, snapshot) {
//
//                   if (!snapshot.hasData) {
//                     return const LinearProgressIndicator();
//                   }
//
//                   final products = snapshot.data!;
//
//                   return DropdownButtonFormField<String>(
//                     value: selectedProductId,
//
//                     decoration: const InputDecoration(
//                       labelText: "Select Product",
//                       prefixIcon: Icon(Icons.shopping_bag),
//                       border: OutlineInputBorder(),
//                     ),
//
//                     items: products.map((p) {
//                       final data = p.data() as Map<String, dynamic>;
//
//                       return DropdownMenuItem(
//                         value: p.id,
//                         child: Text(data['title'] ?? "Product"),
//                       );
//                     }).toList(),
//
//                     onChanged: (val) async {
//
//                       if (val == null) return;
//
//                       setState(() {
//                         selectedProductId = val;
//                         selectedProductData = null;
//                       });
//
//                       final snap =
//                       await firestore.collection("products").doc(val).get();
//
//                       if (snap.exists) {
//                         setState(() {
//                           selectedProductData = snap.data();
//                         });
//                       }
//                     },
//                   );
//                 },
//               ),
//
//               if (selectedProductData != null) ...[
//                 const SizedBox(height: 12),
//                 buildProductPreview(selectedProductData!),
//
//                 const SizedBox(height: 12),
//
//                 buildInput(
//                   controller: qtyCtrl,
//                   label: "Product Quantity",
//                   icon: Icons.production_quantity_limits,
//                   isNumber: true,
//                 ),
//               ],
//
//               if (selectedProductId != null) ...[
//
//                 const SizedBox(height: 14),
//
//                 // ================= SOURCE =================
//
//                 DropdownButtonFormField<String>(
//                   value: selectedSource,
//
//                   decoration: const InputDecoration(
//                     labelText: "Source Of Enquiry",
//                     prefixIcon: Icon(Icons.source),
//                     border: OutlineInputBorder(),
//                   ),
//
//                   items: enquirySources.map((e) {
//                     return DropdownMenuItem(
//                       value: e['value'],
//                       child: Text(e['label']!),
//                     );
//                   }).toList(),
//
//                   onChanged: (val) {
//                     setState(() => selectedSource = val);
//                   },
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // ================= EXPECTED DATE =================
//
//                 InkWell(
//                   onTap: pickExpectedDate,
//
//                   child: InputDecorator(
//                     decoration: const InputDecoration(
//                       labelText: "Expected Date",
//                       prefixIcon: Icon(Icons.calendar_month),
//                       border: OutlineInputBorder(),
//                     ),
//
//                     child: Text(
//                       expectedDate == null
//                           ? "Select Date"
//                           : DateFormat.yMMMd().format(expectedDate!),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 buildInput(
//                   controller: titleCtrl,
//                   label: "Enquiry Title",
//                   icon: Icons.title,
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 buildInput(
//                   controller: descCtrl,
//                   label: "Enquiry Description",
//                   icon: Icons.description,
//                   maxLines: 4,
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ================= PRODUCT PREVIEW =================
//
//   Widget buildProductPreview(Map<String, dynamic> p) {
//
//     final pricing = p['pricing'] ?? {};
//     final payment = p['paymentTerms'] ?? {};
//     final specs = p['specifications'] ?? [];
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.lightGrey,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Text(p['title'] ?? "Product",
//               style: const TextStyle(fontWeight: FontWeight.bold)),
//
//           const Divider(),
//
//           infoRow("Base Price", "₹ ${pricing['basePrice'] ?? '-'}"),
//           infoRow("Discount", "${p['discountPercent'] ?? 0}%"),
//           infoRow("Stock", p['stock']?.toString() ?? "-"),
//           infoRow("Delivery", "${p['deliveryTerms'] ?? '-'} months"),
//
//           infoRow("Advance %", payment['advancePaymentPercent']?.toString() ?? "-"),
//           infoRow("Final %", payment['finalPaymentPercent']?.toString() ?? "-"),
//
//           if (specs is List && specs.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             const Text("Specifications",
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             ...specs.map((s) =>
//                 infoRow(s['name'] ?? "-", s['value']?.toString() ?? "-")),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget infoRow(String label, String value) {
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//
//       child: Row(
//         children: [
//           SizedBox(width: 130,
//               child: Text("$label:",
//                   style: const TextStyle(fontWeight: FontWeight.w600))),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
//
//   Widget buildCard({
//     required String title,
//     required IconData icon,
//     required Widget child,
//   }) {
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//       ),
//
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Row(
//             children: [
//               Icon(icon, color: AppColors.darkBlue),
//               const SizedBox(width: 8),
//               Text(title,
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//
//           const Divider(),
//
//           child,
//         ],
//       ),
//     );
//   }
//
//   Widget buildInput({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     int maxLines = 1,
//     bool isNumber = false,
//   }) {
//
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType:
//       isNumber ? TextInputType.number : TextInputType.text,
//
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: const OutlineInputBorder(),
//       ),
//     );
//   }
//
//   void showMsg(String msg) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   @override
//   void dispose() {
//     titleCtrl.dispose();
//     descCtrl.dispose();
//     qtyCtrl.dispose();
//     super.dispose();
//   }
// }
