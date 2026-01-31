import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ClientService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────
  // 🔹 GET CLIENTS (Company Scoped)
  // ─────────────────────────────────────────────
  Stream<QuerySnapshot<Map<String, dynamic>>> getClients() async* {
    final adminId = _auth.currentUser!.uid;
    final adminDoc = await _db.collection('admin').doc(adminId).get();
    final String companyId = adminDoc['companyId'];

    yield* _db
        .collection('clients')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─────────────────────────────────────────────
  // 🔹 CREATE CLIENT (FULL DATA + AUTH USER)
  // ─────────────────────────────────────────────
  Future<void> createClient({
    required String companyName,
    required String customerCode,
    required String socialSecurityNumber,
    required String einTin,
    required String vatIdentifier,

    required String firstName,
    required String lastName,
    required String contactPerson,
    required String emailAddress,

    required String phoneNo1,
    required String phoneNo2,
    required String cellphone,
    required String faxNo,

    required String country,
    required String street,
    required String city,
    required String state,
    required String postcode,
  }) async {
    const tempPassword = 'Temp@1234';

    // 1️⃣ Get companyId from admin
    final adminId = _auth.currentUser!.uid;
    final adminDoc = await _db.collection('admin').doc(adminId).get();
    final String companyId = adminDoc['companyId'];

    // 2️⃣ Create SECONDARY Firebase App
    final FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'ClientSecondary',
      options: Firebase.app().options,
    );

    final FirebaseAuth secondaryAuth =
    FirebaseAuth.instanceFor(app: secondaryApp);

    // 3️⃣ Create Firebase Auth user for client
    final UserCredential cred =
    await secondaryAuth.createUserWithEmailAndPassword(
      email: emailAddress,
      password: tempPassword,
    );

    final String clientAuthId = cred.user!.uid;

    // 4️⃣ Create Firestore client document
    await _db.collection('clients').doc(clientAuthId).set({
      'companyId': companyId,

      // ─── Identity ───
      'companyName': companyName,
      'customerCode': customerCode,
      'socialSecurityNumber': socialSecurityNumber,
      'einTin': einTin,
      'vatIdentifier': vatIdentifier,

      // ─── Personal ───
      'firstName': firstName,
      'lastName': lastName,
      'contactPerson': contactPerson,
      'emailAddress': emailAddress,

      // ─── Contact ───
      'phoneNo1': phoneNo1,
      'phoneNo2': phoneNo2,
      'cellphone': cellphone,
      'faxNo': faxNo,

      // ─── Address ───
      'country': country,
      'street': street,
      'city': city,
      'state': state,
      'postcode': postcode,

      // ─── Meta ───
      'profileImage': null,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 5️⃣ Send password reset email
    await secondaryAuth.sendPasswordResetEmail(
      email: emailAddress,
    );

    // 6️⃣ Cleanup secondary app
    await secondaryApp.delete();
  }

  // ─────────────────────────────────────────────
  // 🔹 GET SINGLE CLIENT
  // ─────────────────────────────────────────────
  Stream<DocumentSnapshot<Map<String, dynamic>>> getClientById(
      String clientId,
      ) {
    return _db.collection('clients').doc(clientId).snapshots();
  }

  // ─────────────────────────────────────────────
  // 🔹 ACTIVATE / DEACTIVATE CLIENT
  // ─────────────────────────────────────────────
  Future<void> toggleStatus({
    required String clientId,
    required bool activate,
  }) async {
    await _db.collection('clients').doc(clientId).update({
      'status': activate ? 'active' : 'inactive',
    });
  }
}
