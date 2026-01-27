import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 🔹 Get companyId from admin
  Future<String> _getCompanyId() async {
    final adminId = _auth.currentUser!.uid;
    final adminDoc = await _db.collection('admin').doc(adminId).get();
    return adminDoc['companyId'];
  }

  // ================= LIST PRODUCTS (Company Scoped) =================
  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts() async* {
    final companyId = await _getCompanyId();

    yield* FirebaseFirestore.instance
        .collection('products')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }



  // ================= PRODUCT BY ID =================
  Stream<DocumentSnapshot<Map<String, dynamic>>> getProductById(
      String productId) {
    return _db.collection('products').doc(productId).snapshots();
  }

  // ================= CREATE PRODUCT =================
  Future<void> createProduct(Map<String, dynamic> data) async {
    final companyId = await _getCompanyId();

    await _db.collection('products').add({
      ...data,
      'companyId': companyId,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= UPDATE PRODUCT (NEW) =================
  /// 🔥 Used by ProductDetailScreen inline edit
  /// 🔥 Partial updates (only the edited card)
  Future<void> updateProduct(
      String productId,
      Map<String, dynamic> updates,
      ) async {
    await _db.collection('products').doc(productId).update(updates);
  }

  // ================= TOGGLE STATUS =================
  Future<void> toggleProductStatus({
    required String productId,
    required bool active,
  }) async {
    await _db.collection('products').doc(productId).update({
      'active': active,
    });
  }

  // ================= DELETE PRODUCT (OPTIONAL) =================
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}
