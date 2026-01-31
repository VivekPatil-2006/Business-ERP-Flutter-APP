import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/widgets/admin_drawer.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/sales_manager_service.dart';
import 'sales_manager_detail_screen.dart'; // ✅ NEW IMPORT

class SalesManagerListScreen extends StatelessWidget {
  const SalesManagerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/salesManagers'),

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Sales Managers',
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
          Navigator.pushNamed(context, '/createSalesManager');
        },
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: SalesManagerService().getSalesManagers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading sales managers\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(
              message: 'Loading sales managers...',
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyState(
              title: 'No Sales Managers',
              message:
              'You haven’t added any sales managers yet.\nTap + to create one.',
              icon: Icons.groups_outlined,
            );
          }

          final managers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: managers.length,
            itemBuilder: (context, index) {
              final doc = managers[index];
              final data = doc.data();

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SalesManagerDetailScreen(
                        managerId: doc.id,
                      ),
                    ),
                  );
                },
                child: _SalesManagerCard(
                  managerId: doc.id,
                  name: data['name'] ?? '',
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

class _SalesManagerCard extends StatelessWidget {
  final String managerId;
  final String name;
  final String email;
  final String status;

  const _SalesManagerCard({
    required this.managerId,
    required this.name,
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
              Icons.person,
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
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // 🔁 Toggle Status
          Column(
            children: [
              Switch(
                value: isActive,
                activeColor: AppColors.primaryBlue,
                onChanged: (value) {
                  SalesManagerService().toggleStatus(
                    managerId: managerId,
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
