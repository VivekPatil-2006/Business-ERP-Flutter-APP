import 'package:flutter/material.dart';

import '../shared/widgets/admin_drawer.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/client_service.dart';
import 'client_detail_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  String _searchQuery = '';
  late Future<List<Map<String, dynamic>>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  void _loadClients() {
    _clientsFuture = ClientService().getClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/clients'),
      backgroundColor: AppColors.lightGrey,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Clients',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.pushNamed(context, '/createClient');
          _loadClients();
          setState(() {});
        },
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search client...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📋 CLIENT LIST
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator(
                    message: 'Loading clients...',
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final allClients = snapshot.data ?? [];

                final clients = allClients.where((c) {
                  final name =
                  (c['clientName'] ?? '').toString().toLowerCase();
                  final company =
                  (c['companyName'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) ||
                      company.contains(_searchQuery);
                }).toList();

                if (clients.isEmpty) {
                  return const EmptyState(
                    title: 'No Clients',
                    message:
                    'No clients found.\nTry searching or create a new client.',
                    icon: Icons.business_outlined,
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryBlue,
                  onRefresh: () async {
                    _loadClients();
                    setState(() {});
                    await _clientsFuture;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final data = clients[index];
                      final isActive = data['status'] == 'active';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonBlue.withOpacity(0.08),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                              AppColors.primaryBlue.withOpacity(0.15),
                              child: const Icon(
                                Icons.business,
                                color: AppColors.primaryBlue,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['clientName'] ??
                                        data['companyName'] ??
                                        '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['companyName'] ?? '',
                                    style:
                                    const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    data['email'] ?? '',
                                    style:
                                    const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),

                            // 🔁 STATUS
                            Column(
                              children: [
                                Switch(
                                  value: isActive,
                                  activeColor:
                                  AppColors.primaryBlue,
                                  onChanged: (v) async {
                                    await ClientService().toggleStatus(
                                      clientId: data['clientId'],
                                      activate: v,
                                    );
                                    _loadClients();
                                    setState(() {});
                                  },
                                ),
                                Text(
                                  isActive ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).inkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClientDetailScreen(
                                clientId: data['clientId'],
                              ),
                            ),
                          );
                          _loadClients();
                          setState(() {});
                        },
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

/// 🪄 InkWell helper
extension _InkWellExt on Widget {
  Widget inkWell({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: this,
      ),
    );
  }
}
