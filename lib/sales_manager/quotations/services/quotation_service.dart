import '../../../../services/api_service.dart';

class QuotationService {
  /* =======================================================
     CREATE QUOTATION
     POST /api/quotations
     ======================================================= */
  Future<void> createQuotation({
    required String enquiryId,
    required double baseAmount,
    required double discountPercent,
    required double cgstPercent,
    required double sgstPercent,
    required int quantity,
    double? extraDiscount,
    DateTime? possibleDeliveryDate,
  }) async {
    await ApiService.post(
      '/quotations',
      {
        'enquiryId': enquiryId,
        'baseAmount': baseAmount,
        'discountPercent': discountPercent,
        'cgstPercent': cgstPercent,
        'sgstPercent': sgstPercent,
        'quantity': quantity,
        if (extraDiscount != null) 'extraDiscount': extraDiscount,
        if (possibleDeliveryDate != null)
          'possibleDeliveryDate':
          possibleDeliveryDate.toIso8601String(),
      },
    );
  }

  /* =======================================================
     LIST QUOTATIONS
     GET /api/quotations
     ======================================================= */
  Future<List<Map<String, dynamic>>> getQuotations() async {
    final response = await ApiService.get('/quotations');
    return List<Map<String, dynamic>>.from(
      response['quotations'] ?? [],
    );
  }

  Future<Map<String, dynamic>> getQuotationById(
      String quotationId) async {
    final response = await ApiService.get('/quotations');
    final list =
    List<Map<String, dynamic>>.from(response['quotations']);

    return list.firstWhere(
          (q) => q['quotationId'] == quotationId,
    );
  }
}
