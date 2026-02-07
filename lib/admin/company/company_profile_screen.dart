import 'dart:convert';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../shared/widgets/admin_drawer.dart';
import 'services/company_service.dart';
import 'company_edit_screen.dart';
import 'bank_edit_screen.dart';

class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/companyProfile'),
      backgroundColor: AppColors.lightGrey,

      appBar: AppBar(
        title: const Text(
          'Company Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: CompanyService().getCompany(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(
              message: 'Loading company profile...',
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final bank = data['bankDetails'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🖼️ COMPANY LOGO HEADER
                if (data['logoImage'] != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration(),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          base64Decode(data['logoImage']),
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                // 🏢 COMPANY INFO
                _sectionCard(
                  title: 'Company Information',
                  backgroundColor: const Color(0xFFE8FFF1),
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CompanyEditScreen(),
                      ),
                    );
                  },
                  children: [
                    _infoRow('Company Name', data['companyName']),
                    _infoRow('TIN / GST', data['companyTIN']),
                    _infoRow('Website', data['companyWebsite']),
                    _infoRow('Contact Person', data['contactPerson']),
                    _infoRow('Contact Email', data['contactEmail']),
                    _infoRow('Contact Phone', data['contactPhone']),
                    _infoRow('Address', data['address'], multiline: true),
                  ],
                ),

                const SizedBox(height: 20),

                // 🏦 BANK INFO
                _sectionCard(
                  title: 'Bank Details',
                  backgroundColor: const Color(0xFFFFEEF2),
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BankEditScreen(),
                      ),
                    );
                  },
                  children: [
                    _infoRow('Bank Name', bank['bankName']),
                    _infoRow('Branch', bank['branchName']),
                    _infoRow(
                        'Account Holder', bank['accountHolderName']),
                    _infoRow(
                        'Account Number', bank['bankAccountNumber']),
                    _infoRow('IFSC Code', bank['ifscCode']),
                    _infoRow('Account Type', bank['accountType']),
                    _infoRow('UPI ID', bank['upiId']),

                    const SizedBox(height: 14),

                    // 📷 QR IMAGE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 130,
                          child: Text(
                            'QR Scanner',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Expanded(
                          child: bank['scannerImage'] != null
                              ? Container(
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(12),
                              color: AppColors.lightGrey,
                            ),
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(
                                    bank['scannerImage']),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                              : Container(
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(12),
                              color: AppColors.lightGrey,
                            ),
                            child: const Center(
                              child: Text(
                                'No QR image uploaded',
                                style:
                                TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
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

  static BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AppColors.neonBlue.withOpacity(0.08),
          blurRadius: 18,
          spreadRadius: 2,
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
    required Color backgroundColor,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration().copyWith(color: backgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(
      String label,
      String? value, {
        bool multiline = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
        multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? '-' : value,
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
