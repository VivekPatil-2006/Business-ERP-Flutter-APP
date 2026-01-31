import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/client_service.dart';

class ClientDetailScreen extends StatelessWidget {
  final String clientId;

  const ClientDetailScreen({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Client Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ClientService().getClientById(clientId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading client'));
          }

          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading details...');
          }

          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(child: Text('Client not found'));
          }

          final bool isActive = data['status'] == 'active';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🏢 Client Profile Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonBlue.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                        AppColors.primaryBlue.withOpacity(0.15),
                        child: const Icon(
                          Icons.business,
                          size: 40,
                          color: AppColors.primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        data['companyName'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        data['email'] ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 14),

                      _infoRow('Contact', data['contactPerson'] ?? ''),
                      _infoRow('Phone', data['phone'] ?? ''),
                      _infoRow('City', data['city'] ?? ''),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🔁 Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
