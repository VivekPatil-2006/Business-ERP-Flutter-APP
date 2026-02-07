import '../../../../services/api_service.dart';

class InvoiceService {
  Future<List<Map<String, dynamic>>> getInvoices() async {
    final response = await ApiService.get('/invoices');
    return List<Map<String, dynamic>>.from(response['invoices'] ?? []);
  }
}
