import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  // 🔁 Change this when deploying
  //static const String baseUrl = "https://j3rpjd6r-8000.inc1.devtunnels.ms/api";
  static const String baseUrl = "http://10.227.156.212:8000/api";

  /* =======================================================
     🔐 Get Firebase ID Token (PRIVATE ROUTES)
     ======================================================= */
  static Future<String> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    final String? token = await user.getIdToken(true);

    if (token == null || token.isEmpty) {
      throw Exception("Failed to retrieve Firebase ID token");
    }

    return token;
  }

  /* =======================================================
     🌐 POST (PUBLIC – NO AUTH HEADER)
     ======================================================= */
  static Future<Map<String, dynamic>> postPublic(
      String path,
      Map<String, dynamic> body,
      ) async {
    final response = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    _handleError(response);
    return jsonDecode(response.body);
  }

  /* =======================================================
     🌐 GET (PRIVATE)
     ======================================================= */
  static Future<Map<String, dynamic>> get(String path) async {
    final token = await _getIdToken();

    final response = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    _handleError(response);
    return jsonDecode(response.body);
  }

  /* =======================================================
     📤 POST (PRIVATE)
     ======================================================= */
  static Future<Map<String, dynamic>> post(
      String path,
      Map<String, dynamic> body,
      ) async {
    final token = await _getIdToken();

    final response = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    _handleError(response);
    return jsonDecode(response.body);
  }

  /* =======================================================
     ✏️ PATCH (PRIVATE)
     ======================================================= */
  static Future<Map<String, dynamic>> patch(
      String path,
      Map<String, dynamic> body,
      ) async {
    final token = await _getIdToken();

    final response = await http.patch(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    _handleError(response);
    return jsonDecode(response.body);
  }

  /* =======================================================
     🗑 DELETE (PRIVATE)
     ======================================================= */
  static Future<Map<String, dynamic>> delete(String path) async {
    final token = await _getIdToken();

    final response = await http.delete(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    _handleError(response);
    return jsonDecode(response.body);
  }

  /* =======================================================
     ❌ ERROR HANDLING
     ======================================================= */
  static void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      try {
        final body = jsonDecode(response.body);
        throw Exception(
          body["error"] ?? body["message"] ?? response.body,
        );
      } catch (_) {
        throw Exception(response.body);
      }
    }
  }
}
