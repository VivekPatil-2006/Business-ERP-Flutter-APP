import '../../../services/api_service.dart';

class ProductService {
  // ================= LIST PRODUCTS =================
  Future<List<Map<String, dynamic>>> getProducts() async {
    final res = await ApiService.get('/products');
    return List<Map<String, dynamic>>.from(res['products'] ?? []);
  }

  // ================= PRODUCT BY ID =================
  Future<Map<String, dynamic>> getProductById(String productId) async {
    final res = await ApiService.get('/products/$productId');
    return res['product'];
  }

  // ================= CREATE PRODUCT =================
  Future<void> createProduct(Map<String, dynamic> data) async {
    await ApiService.post('/products', data);
  }

  // ================= UPDATE PRODUCT =================
  Future<void> updateProduct(
      String productId,
      Map<String, dynamic> updates,
      ) async {
    await ApiService.patch('/products/$productId', updates);
  }

  // ================= DELETE PRODUCT =================
  Future<void> deleteProduct(String productId) async {
    await ApiService.delete('/products/$productId');
  }
}
