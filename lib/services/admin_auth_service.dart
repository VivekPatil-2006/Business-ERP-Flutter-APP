import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /* =======================================================
     ADMIN REGISTRATION (Already working – unchanged)
     ======================================================= */

  Future<void> registerAdminWithCompany({
    required String adminName,
    required String adminEmail,
    required String adminPhone,
    required String companyName,
    required String contactPerson,
    required String contactEmail,
    required String contactPhone,
  }) async {

    const tempPassword = "Temp@1234";

    try {
      // 1. Create Firebase Auth user
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: tempPassword,
      );

      final String adminId = cred.user!.uid;

      // 2. Create Company
      final companyRef = await _db.collection('companies').add({
        "companyName": companyName,
        "contactPerson": contactPerson,
        "contactEmail": contactEmail,
        "contactPhone": contactPhone,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // 3. Create Admin
      await _db.collection('admin').doc(adminId).set({
        "name": adminName,
        "email": adminEmail,
        "phone": adminPhone,
        "companyId": companyRef.id,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // 4. Send password reset email
      await _auth.sendPasswordResetEmail(email: adminEmail);

    } catch (e) {
      rethrow;
    }
  }

  /* =======================================================
     ADMIN LOGIN
     ======================================================= */

  Future<DocumentSnapshot<Map<String, dynamic>>> loginAdmin({
    required String email,
    required String password,
  }) async {

    try {
      // 1. Firebase Auth login
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String adminId = cred.user!.uid;

      // 2. Verify admin exists in Firestore
      final adminDoc =
      await _db.collection('admin').doc(adminId).get();

      if (!adminDoc.exists) {
        // User is authenticated but NOT an admin
        await _auth.signOut();
        throw Exception("Access denied: Not an admin");
      }

      // 3. Login successful → return admin data
      return adminDoc;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    } catch (e) {
      rethrow;
    }
  }

  /* =======================================================
     FORGOT PASSWORD
     ======================================================= */

  Future<void> sendResetPasswordEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /* =======================================================
     LOGOUT
     ======================================================= */

  Future<void> logout() async {
    await _auth.signOut();
  }

  /* =======================================================
     CURRENT ADMIN (OPTIONAL BUT VERY USEFUL)
     ======================================================= */

  User? get currentUser => _auth.currentUser;
}
