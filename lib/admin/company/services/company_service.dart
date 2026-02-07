import '../../../services/api_service.dart';

class CompanyService {
  /* =======================================================
     🔹 GET COMPANY (LOGGED-IN ADMIN COMPANY)
     GET /api/company/me
     ======================================================= */
  Future<Map<String, dynamic>> getCompany() async {
    final response = await ApiService.get("/company/me");

    // Backend should return: { company: { ... } }
    return response["company"];
  }

  /* =======================================================
     🔹 UPDATE COMPANY PROFILE
     PATCH /api/company/me
     ======================================================= */
  Future<void> updateCompany(Map<String, dynamic> data) async {
    await ApiService.patch(
      "/company/me",
      data,
    );
  }
}
