import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> getUserRole(String uid) async {

    // SALES MANAGER CHECK
    final managerSnap = await _db
        .collection('sales_managers')
        .doc(uid)
        .get();

    if (managerSnap.exists) {
      return "sales_manager";
    }

    // CLIENT CHECK
    final clientSnap = await _db
        .collection('clients')
        .doc(uid)
        .get();

    if (clientSnap.exists) {
      return "client";
    }

    return null;
  }
}
