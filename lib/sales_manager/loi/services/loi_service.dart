import '../../../../services/api_service.dart';

class LoiService {
  // ================================
  // GET ALL LOIs
  // GET /api/lois
  // ================================
  Future<List<Map<String, dynamic>>> getLois() async {
    final response = await ApiService.get('/lois');
    return List<Map<String, dynamic>>.from(response['lois'] ?? []);
  }

  // ================================
  // APPROVE LOI
  // PATCH /api/lois/:id/approve
  // ================================
  Future<void> approveLoi(String loiId) async {
    await ApiService.patch('/lois/$loiId/approve', {});
  }

  // ================================
  // REJECT LOI
  // PATCH /api/lois/:id/reject
  // ================================
  Future<void> rejectLoi(String loiId) async {
    await ApiService.patch('/lois/$loiId/reject', {});
  }

  /* ======================================
     SEND ACK / CREATE OR UPDATE LOI
     POST /api/lois
     ====================================== */
  Future<void> sendAck({
    required String quotationId,
    required String ackPdfUrl,
  }) async {
    await ApiService.post(
      '/lois',
      {
        'quotationId': quotationId,
        'ackPdfUrl': ackPdfUrl,
        'status': 'pending',
      },
    );
  }
}
