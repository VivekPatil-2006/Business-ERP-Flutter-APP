// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../core/pdf/payment_invoice_pdf_service.dart';
// import '../../core/pdf/pdf_utils.dart';
//
//
// class QuotationListClient extends StatelessWidget {
//   const QuotationListClient({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text("User not logged in")),
//       );
//     }
//
//     final uid = user.uid;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Quotations"),
//       ),
//
//       body: StreamBuilder<QuerySnapshot>(
//
//         stream: FirebaseFirestore.instance
//             .collection("quotations")
//             .where("clientId", isEqualTo: uid)
//             .orderBy("createdAt", descending: true)
//             .snapshots(),
//
//         builder: (context, snapshot) {
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No quotations found"));
//           }
//
//           final quotes = snapshot.data!.docs;
//
//           return ListView.builder(
//
//             itemCount: quotes.length,
//
//             itemBuilder: (context, index) {
//
//               final q = quotes[index];
//               final data = q.data() as Map<String, dynamic>;
//
//               final status = data['status'] ?? "unknown";
//               final amount = (data['quotationAmount'] ?? 0).toDouble();
//               final invoicePdfUrl = data['invoicePdfUrl'];
//
//               return Card(
//                 elevation: 3,
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       // ================= AMOUNT =================
//
//                       Text(
//                         "₹ $amount",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//
//                       const SizedBox(height: 6),
//
//                       // ================= STATUS =================
//
//                       Text(
//                         "Status: ${status.toUpperCase()}",
//                         style: TextStyle(
//                           color: status == "payment_done"
//                               ? Colors.green
//                               : Colors.orange,
//                         ),
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // ================= ACTIONS =================
//
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//
//                           // ---------------- PAY NOW ----------------
//
//                           if (status == "ack_sent")
//
//                             ElevatedButton.icon(
//
//                               icon: const Icon(Icons.payment),
//                               label: const Text("Pay Now"),
//
//                               onPressed: () async {
//
//                                 try {
//
//                                   final invoiceNumber =
//                                       "INV-${DateTime.now().millisecondsSinceEpoch}";
//
//                                   // ---------------- GENERATE PAYMENT INVOICE PDF ----------------
//
//                                   final pdfUrl =
//                                   await PaymentInvoicePdfService()
//                                       .generatePaymentInvoice(
//
//                                     invoiceNumber: invoiceNumber,
//                                     clientName: uid,
//                                     amount: amount,
//                                     paymentMode: "Demo",
//                                   );
//
//                                   // ---------------- SAVE PAYMENT ----------------
//
//                                   await FirebaseFirestore.instance
//                                       .collection("payments")
//                                       .add({
//
//                                     "invoiceNumber": invoiceNumber,
//                                     "clientId": uid,
//
//                                     "quotationId": q.id,
//
//                                     "amount": amount,
//
//                                     "status": "completed",
//
//                                     "paymentMode": "demo",
//                                     "paymentType": "fake",
//
//                                     "createdAt": Timestamp.now(),
//                                   });
//
//                                   // ---------------- CREATE INVOICE ----------------
//
//                                   await FirebaseFirestore.instance
//                                       .collection("invoices")
//                                       .add({
//
//                                     "invoiceNumber": invoiceNumber,
//
//                                     "clientId": uid,
//                                     "quotationId": q.id,
//
//                                     "totalAmount": amount,
//
//                                     "paymentStatus": "paid",
//
//                                     // IMPORTANT PDF STORAGE
//                                     "pdfUrl": pdfUrl,
//                                     "invoicePdfUrl": pdfUrl,
//
//                                     "createdAt": Timestamp.now(),
//                                     "date": Timestamp.now(),
//
//                                     "items": [],
//                                   });
//
//                                   // ---------------- UPDATE QUOTATION ----------------
//
//                                   await FirebaseFirestore.instance
//                                       .collection("quotations")
//                                       .doc(q.id)
//                                       .update({
//
//                                     "status": "payment_done",
//                                     "invoicePdfUrl": pdfUrl,
//                                   });
//
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text("Payment Successful & Invoice Generated"),
//                                     ),
//                                   );
//
//                                 } catch (e) {
//
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text("Payment Failed: $e")),
//                                   );
//                                 }
//                               },
//                             ),
//
//                           // ---------------- VIEW + DOWNLOAD PDF ----------------
//
//                           if (status == "payment_done" && invoicePdfUrl != null)
//
//                             Row(
//                               children: [
//
//                                 IconButton(
//                                   tooltip: "View Invoice",
//                                   icon: const Icon(Icons.visibility),
//
//                                   onPressed: () {
//                                     PdfUtils.openPdf(invoicePdfUrl);
//                                   },
//                                 ),
//
//                                 IconButton(
//                                   tooltip: "Download Invoice",
//                                   icon: const Icon(Icons.download),
//
//                                   onPressed: () async {
//
//                                     await PdfUtils.downloadPdf(
//
//                                       url: invoicePdfUrl,
//                                       fileName: "Invoice_${q.id}",
//                                     );
//
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text("Invoice Downloaded"),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
