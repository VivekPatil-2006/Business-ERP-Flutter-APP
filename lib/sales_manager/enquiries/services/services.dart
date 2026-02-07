import '../../../../services/api_service.dart';

class EnquiryService {
  /* =======================================================
     GET ALL ENQUIRIES
     GET /api/enquiries
     ======================================================= */
  Future<List<Map<String, dynamic>>> getEnquiries() async {
    final response = await ApiService.get('/enquiries');
    final List list = response['enquiries'] ?? [];

    return list.map<Map<String, dynamic>>((e) {
      return {
        'enquiryId': e['enquiryId'],
        'title': e['title'],
        'source': e['source'],
        'status': e['status'],
        'createdAt': e['created_at'],
      };
    }).toList();
  }

  /* =======================================================
     GET ENQUIRY DETAILS
     GET /api/enquiries/:id
     ======================================================= */
  Future<Map<String, dynamic>> getEnquiryDetails(String enquiryId) async {
    final response = await ApiService.get('/enquiries/$enquiryId');
    final e = response['enquiry'];

    return {
      'enquiryId': e['enquiryId'],
      'clientId': e['clientId'],
      'productId': e['productId'],
      'title': e['title'],
      'description': e['description'],
      'quantity': e['quantity'],
      'source': e['source'],
      'status': e['status'],
      'createdAt': e['created_at'],
      'expectedDate': e['expected_date'],
    };
  }

  /* =======================================================
     CREATE ENQUIRY
     POST /api/enquiries
     ======================================================= */
  Future<void> createEnquiry({
    required String clientId,
    required String productId,
    required String title,
    required String description,
    int? quantity,
    String? source,
    DateTime? expectedDate,
  }) async {
    await ApiService.post('/enquiries', {
      'clientId': clientId,
      'productId': productId,
      'title': title,
      'description': description,
      if (quantity != null) 'quantity': quantity,
      if (source != null) 'source': source,
      if (expectedDate != null)
        'expectedDate': expectedDate.toIso8601String(),
    });
  }
}
