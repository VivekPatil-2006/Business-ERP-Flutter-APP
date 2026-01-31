import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Get companyId of logged-in admin
  Future<String> _getCompanyId() async {
    final adminId = _auth.currentUser!.uid;
    final adminDoc = await _db.collection('admin').doc(adminId).get();
    return adminDoc['companyId'];
  }

  /// Fetch company details
  Stream<DocumentSnapshot<Map<String, dynamic>>> getCompany() async* {
    final companyId = await _getCompanyId();
    yield* _db.collection('companies').doc(companyId).snapshots();
  }

  /// Update company profile
  Future<void> updateCompany(Map<String, dynamic> data) async {
    final companyId = await _getCompanyId();
    await _db.collection('companies').doc(companyId).update(data);
  }
}
