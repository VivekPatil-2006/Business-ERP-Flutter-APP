import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /* =======================================================
     🆕 ADMIN SIGNUP (BACKEND + PASSWORD RESET EMAIL)
     ======================================================= */
  Future<void> registerAdminWithCompany({
    required String adminEmail,
    required String companyName,
    String? adminName,
    String? adminPhone,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
  }) async {
    try {
      // 1️⃣ Create admin + company via backend
      await ApiService.postPublic(
        "/auth/signup",
        {
          "adminEmail": adminEmail,
          "companyName": companyName,
          if (adminName != null) "adminName": adminName,
          if (adminPhone != null) "adminPhone": adminPhone,
          if (contactPerson != null) "contactPerson": contactPerson,
          if (contactEmail != null) "contactEmail": contactEmail,
          if (contactPhone != null) "contactPhone": contactPhone,
        },
      );

      // 2️⃣ Send Firebase password reset email
      // (User was already created by backend)
      await _auth.sendPasswordResetEmail(
        email: adminEmail,
      );

    } catch (e) {
      rethrow;
    }
  }

  /* =======================================================
     🔐 LOGIN (Firebase Auth ONLY)
     ======================================================= */
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /* =======================================================
     🔁 VERIFY SESSION (BACKEND ROLE CHECK)
     ======================================================= */
  Future<Map<String, dynamic>> verifySession() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final token = await user.getIdToken(true);

    return await ApiService.postPublic(
      "/auth/login",
      {
        "token": token,
      },
    );
  }

  /* =======================================================
     🚪 LOGOUT
     ======================================================= */
  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
