import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SalesManagerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch all sales managers (company scoped)
  Stream<QuerySnapshot<Map<String, dynamic>>> getSalesManagers() async* {
    final adminId = _auth.currentUser!.uid;
    final adminDoc = await _db.collection('admin').doc(adminId).get();
    final String companyId = adminDoc['companyId'];

    yield* _db
        .collection('sales_managers')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateTargetSales({
    required String managerId,
    required double targetSales,
  }) async {
    await _db.collection('sales_managers').doc(managerId).update({
      'targetSales': targetSales,
    });
  }
  /// Activate / Deactivate Sales Manager
  Future<void> toggleStatus({
    required String managerId,
    required bool activate,
  }) async {
    await _db.collection('sales_managers').doc(managerId).update({
      'status': activate ? 'active' : 'inactive',
    });
  }
  /// Get single sales manager by ID
  Stream<DocumentSnapshot<Map<String, dynamic>>> getSalesManagerById(
      String managerId,
      ) {
    return _db.collection('sales_managers').doc(managerId).snapshots();
  }
  /// ✅ SAFE CREATE SALES MANAGER (NO SESSION SWITCH)
  Future<void> createSalesManager({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String dob,
    required String addressLine1,
    required String addressLine2,
    required String state,
    required String city,
    required String postcode,
  }) async {
    const tempPassword = 'Temp@1234';


    // 1️⃣ Get companyId
    final adminId = _auth.currentUser!.uid;
    final adminDoc = await _db.collection('admin').doc(adminId).get();
    final String companyId = adminDoc['companyId'];

    // 2️⃣ Create SECONDARY Firebase App
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'Secondary',
      options: Firebase.app().options,
    );

    final FirebaseAuth secondaryAuth =
    FirebaseAuth.instanceFor(app: secondaryApp);

    // 3️⃣ Create Sales Manager Auth user
    final UserCredential cred =
    await secondaryAuth.createUserWithEmailAndPassword(
      email: email,
      password: tempPassword,
    );

    final String managerId = cred.user!.uid;

    // 4️⃣ Create Firestore record
    await _db.collection('sales_managers').doc(managerId).set({
      'companyId': companyId,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 5️⃣ Send password reset email
    await secondaryAuth.sendPasswordResetEmail(email: email);

    // 6️⃣ Cleanup secondary app
    await secondaryApp.delete();


  }
}
