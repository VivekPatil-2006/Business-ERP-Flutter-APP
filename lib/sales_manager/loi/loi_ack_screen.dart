// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../core/services/notification_service.dart';
// import '../../core/pdf/pdf_utils.dart';
// import '../../core/theme/app_colors.dart';
// import 'loi_file_viewer.dart';
//
// class LoiAckScreen extends StatefulWidget {
//   const LoiAckScreen({super.key});
//
//   @override
//   State<LoiAckScreen> createState() => _LoiAckScreenState();
// }
//
// class _LoiAckScreenState extends State<LoiAckScreen> {
//
//   String companyId = "";
//   bool loading = true;
//
//   bool actionLoading = false;
//   String processingLoiId = "";
//
//   final firestore = FirebaseFirestore.instance;
//   final auth = FirebaseAuth.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     loadCompany();
//   }
//
//   // ================= LOAD COMPANY =================
//
//   Future<void> loadCompany() async {
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
//       setState(() => loading = false);
//     }
//   }
//
//   // ================= REALTIME LOI STREAM =================
//
//   Stream<QuerySnapshot> fetchCompanyLois() {
//
//     return firestore
//         .collection("loi")
//         .where("companyId", isEqualTo: companyId)
//         .orderBy("createdAt", descending: true)
//         .snapshots();
//   }
//
//   // ================= ACCEPT LOI =================
//
//   Future<void> acceptLoi({
//     required String loiDocId,
//     required String quotationId,
//     required String clientId,
//   }) async {
//
//     try {
//
//       setState(() {
//         actionLoading = true;
//         processingLoiId = loiDocId;
//       });
//
//       // ================= FETCH QUOTATION =================
//
//       final quoteSnap = await firestore
//           .collection("quotations")
//           .doc(quotationId)
//           .get();
//
//       if (!quoteSnap.exists) {
//         debugPrint("Quotation not found");
//         return;
//       }
//
//       final quoteData =
//       quoteSnap.data() as Map<String, dynamic>;
//
//       final double amount =
//       (quoteData['quotationAmount'] ?? 0).toDouble();
//
//       final productSnapshot =
//       quoteData['productSnapshot'];
//
//       // ================= CREATE INVOICE =================
//
//       final invoiceNumber =
//           "INV-${DateTime.now().millisecondsSinceEpoch}";
//
//       final invoiceRef =
//       await firestore.collection("invoices").add({
//
//         "companyId": companyId,
//         "salesManagerId": auth.currentUser!.uid,
//
//         "clientId": clientId,
//         "quotationId": quotationId,
//
//         "invoiceNumber": invoiceNumber,
//
//         "items": [productSnapshot],
//
//         "totalAmount": amount,
//
//         "paymentStatus": "unpaid",
//
//         "pdfUrl": "",
//
//         "createdAt": Timestamp.now(),
//       });
//
//       // ================= UPDATE LOI =================
//
//       await firestore.collection("loi").doc(loiDocId).update({
//
//         "status": "accepted",
//         "invoiceId": invoiceRef.id,
//         "approvedAt": Timestamp.now(),
//       });
//
//       // ================= UPDATE QUOTATION =================
//
//       await firestore.collection("quotations").doc(quotationId).update({
//
//         "status": "loi_sent",
//         "invoiceId": invoiceRef.id,
//       });
//
//       // ================= NOTIFY CLIENT =================
//
//       await NotificationService().sendNotification(
//
//         userId: clientId,
//         role: "client",
//
//         title: "LOI Approved",
//         message: "Invoice has been generated",
//
//         type: "invoice",
//         referenceId: invoiceRef.id,
//       );
//
//     } catch (e) {
//
//       debugPrint("LOI Accept Error => $e");
//
//     } finally {
//
//       if (mounted) {
//         setState(() {
//           actionLoading = false;
//           processingLoiId = "";
//         });
//       }
//     }
//   }
//
//   // ================= REJECT LOI =================
//
//   Future<void> rejectLoi({
//     required String loiDocId,
//     required String quotationId,
//     required String clientId,
//   }) async {
//
//     try {
//
//       setState(() {
//         actionLoading = true;
//         processingLoiId = loiDocId;
//       });
//
//       await firestore.collection("loi").doc(loiDocId).update({
//
//         "status": "rejected",
//         "approvedAt": Timestamp.now(),
//       });
//
//       await firestore.collection("quotations").doc(quotationId).update({
//
//         "status": "rejected",
//       });
//
//       await NotificationService().sendNotification(
//
//         userId: clientId,
//         role: "client",
//
//         title: "LOI Rejected",
//         message: "Your LOI was rejected",
//
//         type: "loi",
//         referenceId: quotationId,
//       );
//
//     } catch (e) {
//
//       debugPrint("LOI Reject Error => $e");
//
//     } finally {
//
//       if (mounted) {
//         setState(() {
//           actionLoading = false;
//           processingLoiId = "";
//         });
//       }
//     }
//   }
//
//   // ================= UI =================
//
//   @override
//   Widget build(BuildContext context) {
//
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text(
//           "LOI Requests",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: AppColors.darkBlue,
//         foregroundColor: Colors.white, // back arrow + icons
//       ),
//
//
//       body: StreamBuilder<QuerySnapshot>(
//
//         stream: fetchCompanyLois(),
//
//         builder: (context, snapshot) {
//
//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return const Center(
//                 child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData ||
//               snapshot.data!.docs.isEmpty) {
//             return const Center(
//                 child: Text("No LOI Requests"));
//           }
//
//           final lois = snapshot.data!.docs;
//
//           return ListView.builder(
//
//             itemCount: lois.length,
//
//             itemBuilder: (context, index) {
//
//               final doc = lois[index];
//
//               final data =
//               doc.data() as Map<String, dynamic>;
//
//               final status =
//                   data['status'] ?? "pending";
//
//               final quotationId =
//               data['quotationId'];
//
//               final clientId =
//               data['clientId'];
//
//               final loiUrl =
//               data['attachmentUrl'];
//
//               final invoiceId =
//               data['invoiceId'];
//
//               return Card(
//                 margin: const EdgeInsets.all(12),
//
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//
//                   child: Column(
//                     crossAxisAlignment:
//                     CrossAxisAlignment.start,
//
//                     children: [
//
//                       Text(
//                         "Quotation ID: $quotationId",
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold),
//                       ),
//
//                       const SizedBox(height: 6),
//
//                       Text(
//                         "Status: ${status.toUpperCase()}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: status == "accepted"
//                               ? Colors.green
//                               : status == "rejected"
//                               ? Colors.red
//                               : Colors.orange,
//                         ),
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       Row(
//                         children: [
//
//                           // VIEW LOI
//                           OutlinedButton.icon(
//                             icon: const Icon(Icons.visibility),
//                             label: const Text("View LOI"),
//
//                             onPressed: loiUrl == null
//                                 ? null
//                                 : () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) =>
//                                       LoiFileViewer(
//                                         url: loiUrl,
//                                         fileType:
//                                         data['fileType'] ??
//                                             "image",
//                                       ),
//                                 ),
//                               );
//                             },
//                           ),
//
//                           const SizedBox(width: 10),
//
//                           // VIEW INVOICE (AFTER ACCEPT)
//                           if (invoiceId != null)
//
//                             OutlinedButton.icon(
//                               icon: const Icon(Icons.receipt),
//                               label:
//                               const Text("Invoice"),
//
//                               onPressed: () async {
//
//                                 final snap =
//                                 await firestore
//                                     .collection("invoices")
//                                     .doc(invoiceId)
//                                     .get();
//
//                                 final pdfUrl =
//                                 snap.data()?['pdfUrl'];
//
//                                 if (pdfUrl != null &&
//                                     pdfUrl != "") {
//                                   PdfUtils.openPdf(pdfUrl);
//                                 }
//                               },
//                             ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       if (status == "pending")
//
//                         Row(
//                           children: [
//
//                             // ACCEPT
//                             Expanded(
//                               child: ElevatedButton(
//                                 style:
//                                 ElevatedButton.styleFrom(
//                                   backgroundColor:
//                                   Colors.green,
//                                 ),
//
//                                 onPressed: actionLoading
//                                     ? null
//                                     : () {
//                                   acceptLoi(
//                                     loiDocId: doc.id,
//                                     quotationId:
//                                     quotationId,
//                                     clientId: clientId,
//                                   );
//                                 },
//
//                                 child: processingLoiId ==
//                                     doc.id &&
//                                     actionLoading
//                                     ? const SizedBox(
//                                   height: 18,
//                                   width: 18,
//                                   child:
//                                   CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color:
//                                     Colors.white,
//                                   ),
//                                 )
//                                     : const Text("ACCEPT"),
//                               ),
//                             ),
//
//                             const SizedBox(width: 10),
//
//                             // REJECT
//                             Expanded(
//                               child: ElevatedButton(
//                                 style:
//                                 ElevatedButton.styleFrom(
//                                   backgroundColor:
//                                   Colors.red,
//                                 ),
//
//                                 onPressed: actionLoading
//                                     ? null
//                                     : () {
//                                   rejectLoi(
//                                     loiDocId: doc.id,
//                                     quotationId:
//                                     quotationId,
//                                     clientId: clientId,
//                                   );
//                                 },
//
//                                 child: processingLoiId ==
//                                     doc.id &&
//                                     actionLoading
//                                     ? const SizedBox(
//                                   height: 18,
//                                   width: 18,
//                                   child:
//                                   CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color:
//                                     Colors.white,
//                                   ),
//                                 )
//                                     : const Text("REJECT"),
//                               ),
//                             ),
//                           ],
//                         ),
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
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'services/loi_service.dart';
import 'loi_file_viewer.dart';

class LoiAckScreen extends StatefulWidget {
  const LoiAckScreen({super.key});

  @override
  State<LoiAckScreen> createState() => _LoiAckScreenState();
}

class _LoiAckScreenState extends State<LoiAckScreen> {
  bool loading = true;
  bool actionLoading = false;
  String processingLoiId = "";

  List<Map<String, dynamic>> lois = [];

  @override
  void initState() {
    super.initState();
    loadLois();
  }

  // ================= LOAD LOIs =================

  Future<void> loadLois() async {
    try {
      final data = await LoiService().getLois();
      if (mounted) {
        setState(() {
          lois = data;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("LOAD LOI ERROR => $e");
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= APPROVE =================

  Future<void> approve(String loiId) async {
    try {
      setState(() {
        actionLoading = true;
        processingLoiId = loiId;
      });

      await LoiService().approveLoi(loiId);
      await loadLois();
    } catch (e) {
      debugPrint("APPROVE LOI ERROR => $e");
    } finally {
      if (mounted) {
        setState(() {
          actionLoading = false;
          processingLoiId = "";
        });
      }
    }
  }

  // ================= REJECT =================

  Future<void> reject(String loiId) async {
    try {
      setState(() {
        actionLoading = true;
        processingLoiId = loiId;
      });

      await LoiService().rejectLoi(loiId);
      await loadLois();
    } catch (e) {
      debugPrint("REJECT LOI ERROR => $e");
    } finally {
      if (mounted) {
        setState(() {
          actionLoading = false;
          processingLoiId = "";
        });
      }
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LOI Requests",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),

      body: lois.isEmpty
          ? const Center(child: Text("No LOI Requests"))
          : ListView.builder(
        itemCount: lois.length,
        itemBuilder: (context, index) {
          final loi = lois[index];
          final status = loi['status'] ?? 'pending';

          final quotation =
          loi['quotation'] as Map<String, dynamic>?;

          final quotationId =
              quotation?['quotationId'] ?? '-';

          final attachmentUrl = loi['attachmentUrl'];
          final fileType = loi['fileType'] ?? 'image';

          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quotation ID: $quotationId",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  _statusChip(status),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon:
                        const Icon(Icons.visibility),
                        label:
                        const Text("View LOI"),
                        onPressed: attachmentUrl ==
                            null ||
                            attachmentUrl == ""
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LoiFileViewer(
                                    url: attachmentUrl,
                                    fileType: fileType,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (status == "pending")
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              Colors.green,
                            ),
                            onPressed: actionLoading
                                ? null
                                : () =>
                                approve(loi['loiId']),
                            child: processingLoiId ==
                                loi['loiId'] &&
                                actionLoading
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text("ACCEPT"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              Colors.red,
                            ),
                            onPressed: actionLoading
                                ? null
                                : () =>
                                reject(loi['loiId']),
                            child: processingLoiId ==
                                loi['loiId'] &&
                                actionLoading
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text("REJECT"),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= STATUS CHIP =================

  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case "accepted":
        color = Colors.green;
        break;
      case "rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
