import '../../../services/api_service.dart';

class ClientService {
  /* =======================================================
     🔹 CREATE CLIENT
     POST /clients
     ======================================================= */
  Future<void> createClient({
    required String companyName,

    String? customerCode,
    String? einTin,
    String? vatIdentifier,
    String? socialSecurityNumber,

    String? contactPerson,
    String? phoneNo1,
    String? phoneNo2,
    String? cellphone,
    String? faxNo,

    String? street,
    String? city,
    String? state,
    String? postcode,
    String? country,
  }) async {
    await ApiService.post(
      '/clients',
      {
        'companyName': companyName,
        'customerCode': customerCode,
        'einTin': einTin,
        'vatIdentifier': vatIdentifier,
        'socialSecurityNumber': socialSecurityNumber,

        'contactPerson': contactPerson,
        'phoneNo1': phoneNo1,
        'phoneNo2': phoneNo2,
        'cellphone': cellphone,
        'faxNo': faxNo,

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
     ======================================================= */
  Future<List<Map<String, dynamic>>> getClients() async {
    final response = await ApiService.get('/clients');
    final List list = response['clients'] ?? [];

    return list.map<Map<String, dynamic>>((c) {
      return {
        'clientId': c['clientId'] ?? c['id'],
        'clientName':
        "${c['firstName'] ?? ''} ${c['lastName'] ?? ''}".trim(),
        'companyName': c['companyName'],
        'email': c['email'],
        'phoneNo1': c['phoneNo1'],
        'createdAt': c['createdAt'],
        'profileImage': c['profileImage'],
      };
    }).toList();
  }

  /* =======================================================
     🔹 GET CLIENT BY ID
     ======================================================= */
  Future<Map<String, dynamic>> getClientById(String clientId) async {
    final response = await ApiService.get('/clients/$clientId');
    final c = response['client'];

    return {
      'clientId': c['clientId'] ?? c['id'],

      // ClientDetails
      'firstName': c['firstName'],
      'lastName': c['lastName'],
      'email': c['email'],
      'contactPerson': c['contactPerson'],
      'phoneNo1': c['phoneNo1'],
      'phoneNo2': c['phoneNo2'],
      'cellphone': c['cellphone'],
      'faxNo': c['faxNo'],
      'profileImage': c['profileImage'],

      // Client
      'companyName': c['companyName'],
      'customerCode': c['customerCode'],
      'einTin': c['einTin'],
      'vatIdentifier': c['vatIdentifier'],
      'socialSecurityNumber': c['socialSecurityNumber'],

      // Address
      'street': c['street'],
      'city': c['city'],
      'state': c['state'],
      'postcode': c['postcode'],
      'country': c['country'],
    };
  }

  /* =======================================================
     🔹 UPDATE CLIENT
     ======================================================= */
  Future<void> updateClient({
    required String clientId,
    required Map<String, dynamic> data,
  }) async {
    await ApiService.patch('/clients/$clientId', data);
  }
}
