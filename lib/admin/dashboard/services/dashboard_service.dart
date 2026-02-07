// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class DashboardService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   // ================= INTERNAL =================
//
//   Future<String> _companyId() async {
//     final uid = _auth.currentUser!.uid;
//     final adminSnap = await _db.collection('admin').doc(uid).get();
//
//     if (!adminSnap.exists) {
//       throw Exception('Admin document not found');
//     }
//
//     return adminSnap.data()!['companyId'];
//   }
//
//   // ================= ENQUIRY ANALYTICS =================
//   // Statuses: raised, quoted
//
//   Future<Map<String, int>> enquiryStats() async {
//     final companyId = await _companyId();
//
//     final snap = await _db
//         .collection('enquiries')
//         .where('companyId', isEqualTo: companyId)
//         .get();
//
//     int total = snap.size;
//     int raised = 0;
//     int quoted = 0;
//
//     for (final doc in snap.docs) {
//       final status = doc.data()['status'];
//
//       if (status == 'raised') raised++;
//       if (status == 'quoted') quoted++;
//     }
//
//     return {
//       'total': total,
//       'raised': raised,
//       'quoted': quoted,
//     };
//   }
//
//   // ================= QUOTATION ANALYTICS =================
//   // Statuses: loi_sent, payment_done
//
//   Future<Map<String, int>> quotationStats() async {
//     final companyId = await _companyId();
//
//     final snap = await _db
//         .collection('quotations')
//         .where('companyId', isEqualTo: companyId)
//         .get();
//
//     int total = snap.size;
//     int loiSent = 0;
//     int paymentDone = 0;
//
//     for (final doc in snap.docs) {
//       final status = doc.data()['status'];
//
//       if (status == 'loi_sent' || status == 'payment_done') {
//         loiSent++;
//       }
//
//       if (status == 'payment_done') {
//         paymentDone++;
//       }
//     }
//
//
//     return {
//       'total': total,
//       'loi_sent': loiSent,
//       'payment_done': paymentDone,
//     };
//   }
//
//   // ================= LOI ANALYTICS =================
//   // Statuses: accepted, rejected, pending
//
//   Future<Map<String, int>> loiStats() async {
//     final companyId = await _companyId();
//
//     final snap = await _db
//         .collection('loi')
//         .where('companyId', isEqualTo: companyId)
//         .get();
//
//     int total = snap.size;
//     int accepted = 0;
//     int rejected = 0;
//     int pending = 0;
//
//     for (final doc in snap.docs) {
//       final status = doc.data()['status'];
//
//       if (status == 'accepted') accepted++;
//       if (status == 'rejected') rejected++;
//       if (status == 'pending') pending++;
//     }
//
//     return {
//       'total': total,
//       'accepted': accepted,
//       'rejected': rejected,
//       'pending': pending,
//     };
//   }
//
//   // ================= PAYMENT ANALYTICS =================
//   // Statuses: completed, pending
//
//   Future<Map<String, double>> paymentStats() async {
//     final companyId = await _companyId();
//
//     final snap = await _db
//         .collection('payments')
//         .where('companyId', isEqualTo: companyId)
//         .get();
//
//     double received = 0;
//     double pending = 0;
//
//     for (final doc in snap.docs) {
//       final data = doc.data();
//       final amount = (data['amount'] ?? 0).toDouble();
//       final status = data['status'];
//
//       if (status == 'completed') {
//         received += amount;
//       } else if (status == 'pending') {
//         pending += amount;
//       }
//     }
//
//     return {
//       'received': received,
//       'pending': pending,
//     };
//   }
//
//   // ================= CLIENT MOVEMENT =================
//   // Raised enquiry but no quotation yet
//
//   Future<int> stalledClients() async {
//     final companyId = await _companyId();
//
//     final snap = await _db
//         .collection('enquiries')
//         .where('companyId', isEqualTo: companyId)
//         .where('status', isEqualTo: 'raised')
//         .get();
//
//     return snap.size;
//   }
// }
