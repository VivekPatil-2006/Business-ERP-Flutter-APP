import 'package:flutter/material.dart';

import '../../client/profile/client_profile_screen.dart';
import '../../core/theme/app_colors.dart';
import 'services/client_services.dart';
import 'create_client_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  String searchText = '';
  late Future<List<Map<String, dynamic>>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = ClientService().getClients();
  }

  // =============================
  // FILTER CLIENTS
  // =============================

  bool _filterClient(Map<String, dynamic> data) {
    final name =
    (data['clientName'] ?? '').toString().toLowerCase();
    final company =
    (data['companyName'] ?? '').toString().toLowerCase();
    final email =
    (data['email'] ?? '').toString().toLowerCase();
    final phone =
    (data['phoneNo1'] ?? '').toString().toLowerCase();

    final query = searchText.toLowerCase();

    return name.contains(query) ||
        company.contains(query) ||
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
        backgroundColor: AppColors.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Clients',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                hintText: 'Search client...',
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                final clients = snapshot.data ?? [];

                final filtered =
                clients.where(_filterClient).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No Clients Found'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _clientsFuture =
                          ClientService().getClients();
                    });
                  },
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final data = filtered[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            AppColors.primaryBlue.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primaryBlue,
                            ),
                          ),

                          // ✅ CLIENT NAME (NOT COMPANY)
                          title: Text(
                            data['clientName'] ?? 'Unnamed Client',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ COMPANY NAME
                              if ((data['companyName'] ?? '').toString().isNotEmpty)
                                Text(
                                  data['companyName'],
                                  style: const TextStyle(fontSize: 13),
                                ),

                              // ✅ EMAIL
                              if ((data['email'] ?? '').toString().isNotEmpty)
                                Text(
                                  data['email'],
                                  style: const TextStyle(fontSize: 12),
                                ),

                              // ✅ PHONE
                              if ((data['phoneNo1'] ?? '').toString().isNotEmpty)
                                Text(
                                  data['phoneNo1'],
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),

                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClientProfileScreen(
                                  clientId: data['clientId'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
