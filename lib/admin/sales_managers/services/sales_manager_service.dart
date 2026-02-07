import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_service.dart';

class SalesManagerService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /* =======================================================
     🔹 GET SALES MANAGERS
     GET /api/sales-managers
     ======================================================= */
  Future<List<Map<String, dynamic>>> getSalesManagers() async {
    final response = await ApiService.get("/sales-managers");

    final List managers = response["salesManagers"] ?? [];

    return managers.map<Map<String, dynamic>>((m) {
      return {
        "managerId": m["id"],
        "name": m["name"],
        "email": m["email"],
        "phone": m["phone"],
        "status": m["status"],
      };
    }).toList();
  }

  /* =======================================================
     🔹 CREATE SALES MANAGER
     POST /api/sales-managers
     + SEND PASSWORD RESET EMAIL
     ======================================================= */
  Future<void> createSalesManager({
    required String name,
    required String email,
    required String phone,
    String? dob,
    String? gender,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postcode,
  }) async {
    // 1️⃣ Backend creates Firebase user + Supabase rows
    await ApiService.post(
      "/sales-managers",
      {
        "name": name,
        "email": email,
        "phone": phone,
        if (dob != null) "dob": dob,
        if (gender != null) "gender": gender,
        if (addressLine1 != null) "addressLine1": addressLine1,
        if (addressLine2 != null) "addressLine2": addressLine2,
        if (city != null) "city": city,
        if (state != null) "state": state,
        if (postcode != null) "postcode": postcode,
      },
    );

    // 2️⃣ Send password reset email
    await _auth.sendPasswordResetEmail(email: email);
  }

  /* =======================================================
     🔹 GET SINGLE SALES MANAGER
     GET /api/sales-managers/:id
     ======================================================= */
  Future<Map<String, dynamic>> getSalesManagerById(String managerId) async {
    final response = await ApiService.get("/sales-managers/$managerId");

    final m = response["salesManager"];

    return {
      "managerId": m["id"],
      "name": m["name"],
      "email": m["email"],
      "phone": m["phone"],
      "dob": m["dob"],
      "gender": m["gender"],
      "addressLine1": m["addressLine1"],
      "addressLine2": m["addressLine2"],
      "city": m["city"],
      "state": m["state"],
      "postcode": m["postcode"],
      "status": m["status"],
    };
  }

  /* =======================================================
     🔹 ACTIVATE / DEACTIVATE
     PATCH /api/sales-managers/:id/status
     ======================================================= */
  Future<void> toggleStatus({
    required String managerId,
    required bool activate,
  }) async {
    await ApiService.patch(
      "/sales-managers/$managerId/status",
      {
        "status": activate ? "active" : "inactive",
      },
    );
  }
}
