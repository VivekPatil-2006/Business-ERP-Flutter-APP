import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= INTERNAL =================

  Future<String> _companyId() async {
    final uid = _auth.currentUser!.uid;
    final adminSnap = await _db.collection('admin').doc(uid).get();

    if (!adminSnap.exists) {
      throw Exception('Admin document not found');
    }

    return adminSnap.data()!['companyId'];
  }

  // ================= ENQUIRY ANALYTICS =================

  Future<Map<String, int>> enquiryStats() async {
    final companyId = await _companyId();

    final snap = await _db
        .collection('enquiries')
        .where('companyId', isEqualTo: companyId)
        .get();

    int total = snap.size;
    int pending = 0;
    int answered = 0;

    for (final doc in snap.docs) {
      final status = doc.data()['status'];

      if (status == 'raised') pending++;
      if (status == 'quoted' || status == 'closed') answered++;
    }

    return {
      'total': total,
      'pending': pending,
      'answered': answered,
    };
  }

  // ================= QUOTATION ANALYTICS =================

  Future<Map<String, int>> quotationStats() async {
    final companyId = await _companyId();

    final snap = await _db
        .collection('quotations')
        .where('companyId', isEqualTo: companyId)
        .get();

    int total = snap.size;
    int accepted = 0;
    int declined = 0;

    for (final doc in snap.docs) {
      final status = doc.data()['status'];

      if (status == 'accepted') accepted++;
      if (status == 'declined') declined++;
    }

    return {
      'total': total,
      'accepted': accepted,
      'declined': declined,
    };
  }

  // ================= PAYMENT ANALYTICS =================

  Future<Map<String, double>> paymentStats() async {
    final companyId = await _companyId();

    final snap = await _db
        .collection('payments')
        .where('companyId', isEqualTo: companyId)
        .get();

    double received = 0;
    double pending = 0;

    for (final doc in snap.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      final status = data['status'];

      if (status == 'completed') {
        received += amount;
      } else if (status == 'pending') {
        pending += amount;
      }
    }

    return {
      'received': received,
      'pending': pending,
    };
  }

  // ================= CLIENT MOVEMENT =================

  /// Clients who raised enquiry but no quotation yet
  Future<int> stalledClients() async {
    final companyId = await _companyId();

    final snap = await _db
        .collection('enquiries')
        .where('companyId', isEqualTo: companyId)
        .where('status', isEqualTo: 'raised')
        .get();

    return snap.size;
  }
}
