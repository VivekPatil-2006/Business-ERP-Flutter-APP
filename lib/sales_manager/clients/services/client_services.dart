import '../../../services/api_service.dart';

class ClientService {
  /* =======================================================
     🔹 CREATE CLIENT
     POST /api/clients
     ======================================================= */
  Future<void> createClient({
    required String firstName,
    required String emailAddress,

    String? lastName,
    String? cellphone,
    String? phoneNo1,
    String? phoneNo2,
    String? faxNo,
    String? contactPerson,
    String? customerCode,
    String? companyName,

    String? einTin,
    String? vatIdentifier,
    String? socialSecurityNumber,

    String? street,
    String? city,
    String? state,
    String? postcode,
    String? country,
  }) async {
    await ApiService.post(
      '/clients',
      {
        'firstName': firstName,
        'lastName': lastName,
        'emailAddress': emailAddress,

        'companyName': companyName,
        'customerCode': customerCode,

        'contactPerson': contactPerson,
        'phoneNo1': phoneNo1,
        'phoneNo2': phoneNo2,
        'cellphone': cellphone,
        'faxNo': faxNo,

        'einTin': einTin,
        'vatIdentifier': vatIdentifier,
        'socialSecurityNumber': socialSecurityNumber,

        'street': street,
        'city': city,
        'state': state,
        'postcode': postcode,
        'country': country,
      },
    );
  }

  /* =======================================================
     🔹 GET CLIENT LIST
     GET /api/clients
     ======================================================= */
  Future<List<Map<String, dynamic>>> getClients() async {
    final response = await ApiService.get('/clients');
    final List list = response['clients'] ?? [];

    return list.map<Map<String, dynamic>>((c) {
      return {
        // IDs
        'clientId': c['clientId'] ?? c['id'],

        // Display
        'clientName':
        "${c['firstName'] ?? ''} ${c['lastName'] ?? ''}".trim(),
        'companyName': c['companyName'],

        // Contact
        'email': c['email'],
        'phoneNo1': c['phoneNo1'],
        'cellphone': c['cellphone'],

        // Metadata
        'createdAt': c['createdAt'],
        'profileImage': c['profileImage'],
      };
    }).toList();
  }

  /* =======================================================
     🔹 GET SINGLE CLIENT
     GET /api/clients/:id
     ======================================================= */
  Future<Map<String, dynamic>> getClientById(String clientId) async {
    final response = await ApiService.get('/clients/$clientId');
    final c = response['client'];

    return {
      'clientId': c['clientId'] ?? c['id'],
      'companyId': c['companyId'],
      'salesManagerId': c['salesManagerId'],

      'firstName': c['firstName'],
      'lastName': c['lastName'],
      'email': c['email'],
      'emailAddress': c['emailAddress'],

      'companyName': c['companyName'],
      'contactPerson': c['contactPerson'],

      'phoneNo1': c['phoneNo1'],
      'phoneNo2': c['phoneNo2'],
      'cellphone': c['cellphone'],
      'faxNo': c['faxNo'],

      'customerCode': c['customerCode'],
      'einTin': c['einTin'],
      'vatIdentifier': c['vatIdentifier'],
      'socialSecurityNumber': c['socialSecurityNumber'],

      'street': c['street'],
      'city': c['city'],
      'state': c['state'],
      'postcode': c['postcode'],
      'country': c['country'],

      'profileImage': c['profileImage'],
      'createdAt': c['createdAt'],
    };
  }

  /* =======================================================
     🔹 ACTIVATE / DEACTIVATE CLIENT
     PATCH /api/clients/:id/status
     ======================================================= */
  Future<void> toggleStatus({
    required String clientId,
    required bool activate,
  }) async {
    await ApiService.patch(
      '/clients/$clientId/status',
      {
        'status': activate ? 'active' : 'inactive',
      },
    );
  }
}
