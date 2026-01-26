import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../client/profile/client_profile_screen.dart';
import '../../core/theme/app_colors.dart';
import 'create_client_screen.dart';


class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  String searchText = "";
  String companyId = "";

  // =============================
  // LOAD SALES MANAGER COMPANY
  // =============================

  Future<void> loadCompany() async {

    final uid = auth.currentUser!.uid;

    final snap = await firestore
        .collection("sales_managers")
        .doc(uid)
        .get();

    setState(() {
      companyId = snap.data()?['companyId'] ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    loadCompany();
  }

  // =============================
  // FILTER CLIENTS
  // =============================

  bool filterClient(Map<String, dynamic> data) {

    final name =
    (data['companyName'] ?? "").toString().toLowerCase();

    final email =
    (data['emailAddress'] ?? "").toString().toLowerCase();

    final phone =
    (data['phoneNo1'] ?? "").toString().toLowerCase();

    final query = searchText.toLowerCase();

    return name.contains(query) ||
        email.contains(query) ||
        phone.contains(query);
  }

  // =============================
  // UI
  // =============================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Clients"),
        backgroundColor: AppColors.darkBlue,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateClientScreen(),
            ),
          );
        },
      ),

      body: Column(
        children: [

          // ================= SEARCH =================

          Padding(
            padding: const EdgeInsets.all(12),

            child: TextField(
              decoration: InputDecoration(
                hintText: "Search client...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onChanged: (val) {
                setState(() => searchText = val);
              },
            ),
          ),

          // ================= CLIENT LIST =================

          Expanded(
            child: companyId.isEmpty

                ? const Center(child: CircularProgressIndicator())

                : StreamBuilder<QuerySnapshot>(

              stream: firestore
                  .collection("clients")
                  .where("companyId", isEqualTo: companyId)
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No Clients Found"));
                }

                // Apply Search Filter
                final clients = docs.where((doc) {

                  final data =
                  doc.data() as Map<String, dynamic>;

                  return filterClient(data);

                }).toList();

                if (clients.isEmpty) {
                  return const Center(child: Text("No Match Found"));
                }

                return ListView.builder(
                  itemCount: clients.length,

                  itemBuilder: (context, index) {

                    final c = clients[index];
                    final data = c.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),

                      child: ListTile(

                        leading: CircleAvatar(
                          backgroundColor:
                          AppColors.primaryBlue.withOpacity(0.1),

                          child: const Icon(
                            Icons.business,
                            color: AppColors.primaryBlue,
                          ),
                        ),

                        title: Text(
                          data['companyName'] ?? "",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(data['emailAddress'] ?? ""),

                            Text(
                              data['phoneNo1'] ?? "",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClientProfileScreen(
                                clientId: c.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
