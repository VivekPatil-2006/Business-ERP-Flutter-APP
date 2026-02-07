import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/sales_manager_service.dart';

class SalesManagerDetailScreen extends StatelessWidget {
  final String managerId;

  const SalesManagerDetailScreen({super.key, required this.managerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Sales Manager Details',
            style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: SalesManagerService().getSalesManagerById(managerId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator(message: 'Loading details...');
          }

          final m = snapshot.data!;
          final bool isActive = m["status"] == 'active';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _card('Profile', [
                _info('Name', m["name"]),
                _info('Email', m["email"]),
                _info('Phone', m["phone"]),
                _info('Gender', m["gender"]),
                _info('DOB', m["dob"]),
              ]),
              const SizedBox(height: 16),
              _card('Address', [
                _info('Address 1', m["addressLine1"]),
                _info('Address 2', m["addressLine2"]),
                _info('City', m["city"]),
                _info('State', m["state"]),
                _info('Postcode', m["postcode"]),
              ]),
              const SizedBox(height: 16),
              _card('Status', [
                SwitchListTile(
                  value: isActive,
                  title: Text(isActive ? 'Active' : 'Inactive'),
                  onChanged: (v) async {
                    await SalesManagerService().toggleStatus(
                      managerId: managerId,
                      activate: v,
                    );

                    // 🔁 force UI refresh by reloading screen
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SalesManagerDetailScreen(
                            managerId: managerId,
                          ),
                        ),
                      );
                    }
                  },
                ),

              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }
}
