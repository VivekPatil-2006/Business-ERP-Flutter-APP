import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final _db = FirebaseFirestore.instance;

  Future<String?> getUserRole(String uid) async {

    // Check Sales Manager
    final manager = await _db
        .collection('sales_managers')
        .doc(uid)
        .get();

    if (manager.exists) return "sales_manager";

    // Check Client
    final client = await _db
        .collection('clients')
        .doc(uid)
        .get();

    if (client.exists) return "client";

    return null;
  }
}
