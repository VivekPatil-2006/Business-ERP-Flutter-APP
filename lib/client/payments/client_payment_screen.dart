// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../../core/services/cloudinary_service.dart';
// import '../../core/services/notification_service.dart';
// import '../../core/theme/app_colors.dart';
//
// class ClientPaymentScreen extends StatefulWidget {
//   const ClientPaymentScreen({super.key});
//
//   @override
//   State<ClientPaymentScreen> createState() => _ClientPaymentScreenState();
// }
//
// class _ClientPaymentScreenState extends State<ClientPaymentScreen> {
//
//   final firestore = FirebaseFirestore.instance;
//   final auth = FirebaseAuth.instance;
//
//   String? selectedInvoiceId;
//   Map<String, dynamic>? selectedInvoiceData;
//
//   String phase = "phase1";
//   String paymentMode = "upi";
//
//   final amountCtrl = TextEditingController();
//
//   File? proofFile;
//
//   bool loading = false;
//
//   // ================= PICK IMAGE =================
//
//   Future<void> pickImage() async {
//
//     final picked =
//     await ImagePicker().pickImage(source: ImageSource.gallery);
//
//     if (picked != null) {
//       setState(() {
//         proofFile = File(picked.path);
//       });
//     }
//   }
//
//   // ================= SUBMIT PAYMENT =================
//
//   Future<void> submitPayment() async {
//
//     if (proofFile == null ||
//         selectedInvoiceId == null ||
//         selectedInvoiceData == null ||
//         amountCtrl.text.isEmpty) {
//
//       showMsg("Complete all fields");
//       return;
//     }
//
//     try {
//
//       setState(() => loading = true);
//
//       final uid = auth.currentUser!.uid;
//
//       final proofUrl =
//       await CloudinaryService().uploadFile(proofFile!);
//
//       final quotationId =
//       selectedInvoiceData!['quotationId'];
//
//       final companyId =
//       selectedInvoiceData!['companyId'];
//
//       final salesManagerId =
//       selectedInvoiceData!['salesManagerId'];
//
//       final invoiceNumber =
//       selectedInvoiceData!['invoiceNumber'];
//
//       final paymentType =
//       (paymentMode == "upi" || paymentMode == "net_banking")
//           ? "online"
//           : "offline";
//
//       final double amount =
//           double.tryParse(amountCtrl.text) ?? 0;
//
//       // SAVE PAYMENT
//       await firestore.collection('payments').add({
//
//         "invoiceId": selectedInvoiceId,
//         "invoiceNumber": invoiceNumber,
//
//         "quotationId": quotationId,
//         "companyId": companyId,
//
//         "clientId": uid,
//         "salesManagerId": salesManagerId,
//
//         "amount": amount,
//
//         "phase": phase,
//         "paymentType": paymentType,
//         "paymentMode": paymentMode,
//
//         "paymentProofUrl": proofUrl,
//
//         "status": "completed",
//         "createdAt": Timestamp.now(),
//       });
//
//       // UPDATE INVOICE
//       await firestore
//           .collection("invoices")
//           .doc(selectedInvoiceId)
//           .update({
//
//         "paymentStatus": "paid",
//         "paidAt": Timestamp.now(),
//       });
//
//       // UPDATE QUOTATION
//       if (quotationId != null) {
//         await firestore
//             .collection("quotations")
//             .doc(quotationId)
//             .update({
//
//           "status": "payment_done",
//           "updatedAt": Timestamp.now(),
//         });
//       }
//
//       // NOTIFY SALES
//       await NotificationService().sendNotification(
//
//         userId: salesManagerId,
//         role: "sales_manager",
//
//         title: "Payment Completed",
//         message:
//         "Client completed payment for Invoice $invoiceNumber",
//
//         type: "payment",
//         referenceId: quotationId,
//       );
//
//       showMsg("Payment Successful ✅");
//
//       Navigator.pop(context);
//
//     } catch (e) {
//
//       debugPrint("Payment Error => $e");
//       showMsg("Payment Failed");
//
//     } finally {
//
//       if (mounted) {
//         setState(() => loading = false);
//       }
//     }
//   }
//
//   // ================= UI =================
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       appBar: AppBar(
//         backgroundColor: AppColors.darkBlue,
//         elevation: 0,
//
//         // 👈 back arrow & icons in white
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//
//         // 👈 title text in white
//         title: const Text(
//           "Make Payment",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(12),
//
//         child: SizedBox(
//           width: double.infinity,
//
//           child: ElevatedButton(
//
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.darkBlue,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//
//             onPressed: loading ? null : submitPayment,
//
//             child: loading
//                 ? const SizedBox(
//               height: 20,
//               width: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: Colors.white,
//               ),
//             )
//                 : const Text(
//               "SUBMIT PAYMENT",
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//         ),
//       ),
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//
//         child: Column(
//           children: [
//
//             buildCard(
//               title: "Invoice Selection",
//               icon: Icons.receipt_long,
//               child: buildInvoiceDropdown(),
//             ),
//
//             const SizedBox(height: 16),
//
//             buildCard(
//               title: "Payment Details",
//               icon: Icons.payment,
//
//               child: Column(
//                 children: [
//
//                   TextField(
//                     controller: amountCtrl,
//                     keyboardType: TextInputType.number,
//
//                     decoration: const InputDecoration(
//                       labelText: "Amount",
//                       prefixIcon: Icon(Icons.currency_rupee),
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   buildPhaseDropdown(),
//
//                   const SizedBox(height: 12),
//
//                   buildModeDropdown(),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             buildCard(
//               title: "Payment Proof",
//               icon: Icons.upload_file,
//
//               child: Column(
//                 children: [
//
//                   SizedBox(
//                     width: double.infinity,
//
//                     child: OutlinedButton.icon(
//                       icon: const Icon(Icons.upload),
//                       label: const Text("Upload Proof"),
//                       onPressed: pickImage,
//                     ),
//                   ),
//
//                   const SizedBox(height: 10),
//
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//
//                       Icon(
//                         proofFile == null
//                             ? Icons.cancel
//                             : Icons.check_circle,
//
//                         color: proofFile == null
//                             ? Colors.red
//                             : Colors.green,
//                       ),
//
//                       const SizedBox(width: 6),
//
//                       Flexible(
//                         child: Text(
//                           proofFile == null
//                               ? "No file selected"
//                               : "Proof uploaded",
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ================= REALTIME INVOICE DROPDOWN =================
//
//   Widget buildInvoiceDropdown() {
//
//     final uid = auth.currentUser!.uid;
//
//     return StreamBuilder<QuerySnapshot>(
//
//       stream: firestore
//           .collection("invoices")
//           .where("clientId", isEqualTo: uid)
//           .where("paymentStatus", isEqualTo: "unpaid")
//           .orderBy("createdAt", descending: true)
//           .snapshots(),
//
//       builder: (context, snapshot) {
//
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }
//
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Text("No pending invoices");
//         }
//
//         final invoices = snapshot.data!.docs;
//
//         return DropdownButtonFormField<String>(
//
//           isExpanded: true, // ✅ FIX OVERFLOW
//
//           value: selectedInvoiceId,
//
//           decoration: const InputDecoration(
//             labelText: "Select Invoice",
//             border: OutlineInputBorder(),
//           ),
//
//           items: invoices.map((inv) {
//
//             final data =
//             inv.data() as Map<String, dynamic>;
//
//             return DropdownMenuItem<String>(
//               value: inv.id,
//
//               child: Text(
//                 "${data['invoiceNumber']}  |  ₹${data['totalAmount']}",
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             );
//
//           }).toList(),
//
//           onChanged: (val) async {
//
//             if (val == null) return;
//
//             final snap =
//             await firestore.collection("invoices").doc(val).get();
//
//             if (snap.exists) {
//
//               setState(() {
//
//                 selectedInvoiceId = val;
//                 selectedInvoiceData = snap.data();
//
//                 amountCtrl.text =
//                     (snap['totalAmount'] ?? 0).toString();
//               });
//             }
//           },
//         );
//       },
//     );
//   }
//
//   // ================= DROPDOWNS =================
//
//   Widget buildPhaseDropdown() {
//
//     return DropdownButtonFormField<String>(
//
//       isExpanded: true,
//
//       value: phase,
//
//       decoration: const InputDecoration(
//         labelText: "Payment Phase",
//         border: OutlineInputBorder(),
//       ),
//
//       items: const [
//
//         DropdownMenuItem(value: "phase1", child: Text("Advance Payment")),
//         DropdownMenuItem(value: "phase2", child: Text("Interim Payment")),
//         DropdownMenuItem(value: "phase3", child: Text("Final Payment")),
//       ],
//
//       onChanged: (val) {
//         setState(() => phase = val!);
//       },
//     );
//   }
//
//   Widget buildModeDropdown() {
//
//     return DropdownButtonFormField<String>(
//
//       isExpanded: true,
//
//       value: paymentMode,
//
//       decoration: const InputDecoration(
//         labelText: "Payment Mode",
//         border: OutlineInputBorder(),
//       ),
//
//       items: const [
//
//         DropdownMenuItem(value: "upi", child: Text("UPI")),
//         DropdownMenuItem(value: "net_banking", child: Text("Net Banking")),
//         DropdownMenuItem(value: "cash", child: Text("Cash")),
//         DropdownMenuItem(value: "cheque", child: Text("Cheque")),
//       ],
//
//       onChanged: (val) {
//         setState(() => paymentMode = val!);
//       },
//     );
//   }
//
//   // ================= CARD =================
//
//   Widget buildCard({
//     required String title,
//     required IconData icon,
//     required Widget child,
//   }) {
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 6,
//             color: Colors.black.withOpacity(0.05),
//           ),
//         ],
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
//   // ================= MESSAGE =================
//
//   void showMsg(String msg) {
//
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   @override
//   void dispose() {
//
//     amountCtrl.dispose();
//     super.dispose();
//   }
// }
