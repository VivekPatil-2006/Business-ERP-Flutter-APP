import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/app_button.dart';
import 'services/sales_manager_service.dart';

class SalesManagerDetailScreen extends StatefulWidget {
  final String managerId;

  const SalesManagerDetailScreen({
    super.key,
    required this.managerId,
  });

  @override
  State<SalesManagerDetailScreen> createState() =>
      _SalesManagerDetailScreenState();
}

class _SalesManagerDetailScreenState
    extends State<SalesManagerDetailScreen> {
  final TextEditingController targetCtrl = TextEditingController();
  bool isSaving = false;

  @override
  void dispose() {
    targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateTarget() async {
    final target = double.tryParse(targetCtrl.text);
    if (target == null) return;

    setState(() => isSaving = true);

    await SalesManagerService().updateTargetSales(
      managerId: widget.managerId,
      targetSales: target,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target sales updated')),
      );
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,

        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Sales Manager Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: SalesManagerService().getSalesManagerById(widget.managerId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator(message: 'Loading details...');
          }

          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(child: Text('Sales manager not found'));
          }

          final bool isActive = data['status'] == 'active';
          final double targetSales =
          (data['targetSales'] ?? 0).toDouble();
          final double achievedSales =
          (data['achievedSales'] ?? 0).toDouble();

          targetCtrl.text = targetSales.toStringAsFixed(0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ================= PROFILE =================
                _card(
                  title: 'Profile',
                  children: [
                    _info('Name', data['name']),
                    _info('Email', data['email']),
                    _info('Phone', data['phone']),
                    _info('Gender', data['gender']),
                    _info('DOB', data['dob']),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= ADDRESS =================
                _card(
                  title: 'Address',
                  children: [
                    _info('Address Line 1', data['addressLine1']),
                    _info('Address Line 2', data['addressLine2']),
                    _info('City', data['city']),
                    _info('State', data['state']),
                    _info('Postcode', data['postcode']),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= SALES TARGET =================
                _card(
                  title: 'Sales Performance',
                  children: [
                    _info(
                      'Achieved Sales',
                      '₹ ${achievedSales.toStringAsFixed(0)}',
                      highlight: true,
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: targetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Target Sales',
                        filled: true,
                        fillColor: AppColors.lightGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    AppButton(
                      label: 'Update Target',
                      isLoading: isSaving,
                      onPressed: _updateTarget,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= STATUS =================
                _card(
                  title: 'Account Status',
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                            isActive ? Colors.green : Colors.red,
                          ),
                        ),
                        Switch(
                          value: isActive,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (value) {
                            SalesManagerService().toggleStatus(
                              managerId: widget.managerId,
                              activate: value,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _card({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _info(String label, String? value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(
                fontWeight:
                highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight
                    ? AppColors.primaryBlue
                    : AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
