import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/widgets/admin_drawer.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/client_service.dart';
import 'client_detail_screen.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/clients'),

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Clients',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      backgroundColor: AppColors.lightGrey,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/createClient');
        },
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ClientService().getClients(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading clients...');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyState(
              title: 'No Clients',
              message: 'No clients added yet.\nTap + to create one.',
              icon: Icons.business_outlined,
            );
          }

          final clients = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final doc = clients[index];
              final data = doc.data();

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientDetailScreen(clientId: doc.id),
                    ),
                  );
                },
                child: _ClientCard(
                  clientId: doc.id,
                  companyName: data['companyName'] ?? '',
                  contactPerson: data['contactPerson'] ?? '',
                  email: data['email'] ?? '',
                  status: data['status'] ?? 'inactive',
                ),
              );

            },
          );
        },
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final String clientId;
  final String companyName;
  final String contactPerson;
  final String email;
  final String status;

  const _ClientCard({
    required this.clientId,
    required this.companyName,
    required this.contactPerson,
    required this.email,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == 'active';

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
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
            child: const Icon(
              Icons.business,
              color: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contactPerson,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // 🔁 Status Toggle
          Column(
            children: [
              Switch(
                value: isActive,
                activeColor: AppColors.primaryBlue,
                onChanged: (value) {
                  ClientService().toggleStatus(
                    clientId: clientId,
                    activate: value,
                  );
                },
              ),
              Text(
                isActive ? 'ACTIVE' : 'INACTIVE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
