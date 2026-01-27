import 'dart:convert';

import 'package:dealtrack/admin/company/bank_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../shared/widgets/admin_drawer.dart';
import 'services/company_service.dart';

// TEMP: will split later
import 'company_edit_screen.dart';

class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/companyProfile'),
      backgroundColor: AppColors.lightGrey,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Company Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: CompanyService().getCompany(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator(
              message: 'Loading company profile...',
            );
          }

          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(child: Text('Company not found'));
          }

          final bank = data['bankDetails'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🏢 COMPANY LOGO
                if (data['logoImage'] != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonBlue.withOpacity(0.08),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(data['logoImage']),
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                // 🏢 COMPANY DETAILS
                _sectionCard(
                  title: 'Company Information',

                  backgroundColor: const Color(0xFFE8FFF1),

                  action: _editButton(
                    label: 'Edit Company',
                    onTap: () {
                      // NEXT: CompanyInfoEditScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompanyEditScreen(),
                        ),
                      );
                    },
                  ),
                  children: [
                    _infoRow('Company Name', data['companyName']),
                    _infoRow('TIN / GST', data['companyTIN']),
                    _infoRow('Website', data['companyWebsite']),
                    _infoRow('Contact Person', data['contactPerson']),
                    _infoRow('Contact Email', data['contactEmail']),
                    _infoRow('Contact Phone', data['contactPhone']),
                    _infoRow('Address', data['address']),
                    _infoRow(
                      'Terms & Conditions',
                      data['generalTermsAndConditions'],
                      multiline: true,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🏦 BANK DETAILS
                _sectionCard(
                  title: 'Bank Details',
                  backgroundColor: const Color(0xFFFFEEF2), // 🌸 light pink
                  action: _editButton(
                    label: 'Edit Bank',
                    onTap: () {
                      // NEXT: BankDetailsEditScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BankEditScreen(),
                        ),
                      );
                    },
                  ),
                  children: [
                    _infoRow('Bank Name', bank['bankName']),
                    _infoRow('Branch', bank['branchName']),
                    _infoRow('Account Holder', bank['accountHolderName']),
                    _infoRow('Account Number', bank['bankAccountNumber']),
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
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.lightGrey,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(bank['scannerImage']),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                              : Container(
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.lightGrey,
                            ),
                            child: const Center(
                              child: Text(
                                'No QR image uploaded',
                                style: TextStyle(color: Colors.grey),
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

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
    required Color backgroundColor,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonBlue.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
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
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _editButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.edit, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
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

// import 'dart:convert';
//
// import 'package:dealtrack/admin/company/bank_edit_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../core/theme/app_colors.dart';
// import '../../shared/widgets/loading_indicator.dart';
// import '../shared/widgets/admin_drawer.dart';
// import 'services/company_service.dart';
//
// // TEMP: will split later
// import 'company_edit_screen.dart';
//
// class CompanyProfileScreen extends StatelessWidget {
//   const CompanyProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const AdminDrawer(currentRoute: '/companyProfile'),
//
//       // 🌸 Whole screen light pink background
//       backgroundColor: const Color(0xFFFFEEF2),
//
//       appBar: AppBar(
//         backgroundColor: AppColors.navy,
//         elevation: 2,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           'Company Profile',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//
//       body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//         stream: CompanyService().getCompany(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const LoadingIndicator(
//               message: 'Loading company profile...',
//             );
//           }
//
//           final data = snapshot.data!.data();
//           if (data == null) {
//             return const Center(child: Text('Company not found'));
//           }
//
//           final bank = data['bankDetails'] ?? {};
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 // 🏢 COMPANY LOGO
//                 if (data['logoImage'] != null)
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 20),
//                     padding: const EdgeInsets.all(16),
//                     decoration: _cardDecoration(),
//                     child: Center(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.memory(
//                           base64Decode(data['logoImage']),
//                           height: 120,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                 // 🏢 COMPANY DETAILS
//                 _sectionCard(
//                   title: 'Company Information',
//                   actionLabel: 'Edit',
//                   onActionTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const CompanyEditScreen(),
//                       ),
//                     );
//                   },
//                   children: [
//                     _infoRow('Company Name', data['companyName']),
//                     _infoRow('TIN / GST', data['companyTIN']),
//                     _infoRow('Website', data['companyWebsite']),
//                     _infoRow('Contact Person', data['contactPerson']),
//                     _infoRow('Contact Email', data['contactEmail']),
//                     _infoRow('Contact Phone', data['contactPhone']),
//                     _infoRow('Address', data['address']),
//                     _infoRow(
//                       'Terms & Conditions',
//                       data['generalTermsAndConditions'],
//                       multiline: true,
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // 🏦 BANK DETAILS
//                 _sectionCard(
//                   title: 'Bank Details',
//                   actionLabel: 'Edit',
//                   onActionTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const BankEditScreen(),
//                       ),
//                     );
//                   },
//                   children: [
//                     _infoRow('Bank Name', bank['bankName']),
//                     _infoRow('Branch', bank['branchName']),
//                     _infoRow('Account Holder', bank['accountHolderName']),
//                     _infoRow('Account Number', bank['bankAccountNumber']),
//                     _infoRow('IFSC Code', bank['ifscCode']),
//                     _infoRow('Account Type', bank['accountType']),
//                     _infoRow('UPI ID', bank['upiId']),
//
//                     const SizedBox(height: 14),
//
//                     // 📷 QR IMAGE
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(
//                           width: 130,
//                           child: Text(
//                             'QR Scanner',
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ),
//                         Expanded(
//                           child: bank['scannerImage'] != null
//                               ? Container(
//                             height: 120,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color: AppColors.lightGrey,
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.memory(
//                                 base64Decode(bank['scannerImage']),
//                                 fit: BoxFit.contain,
//                               ),
//                             ),
//                           )
//                               : Container(
//                             height: 120,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color: AppColors.lightGrey,
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 'No QR image uploaded',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ================= UI HELPERS =================
//
//   BoxDecoration _cardDecoration() {
//     return BoxDecoration(
//       color: const Color(0xFFF8FAFD), // previous neutral card bg
//       borderRadius: BorderRadius.circular(18),
//       boxShadow: [
//         BoxShadow(
//           color: AppColors.neonBlue.withOpacity(0.08),
//           blurRadius: 18,
//           spreadRadius: 2,
//         ),
//       ],
//     );
//   }
//
//   Widget _sectionCard({
//     required String title,
//     required List<Widget> children,
//     required String actionLabel,
//     required VoidCallback onActionTap,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(22),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // HEADER WITH EDIT BUTTON (clean alignment)
//           Row(
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.navy,
//                 ),
//               ),
//               const Spacer(),
//               TextButton(
//                 onPressed: onActionTap,
//                 child: Text(
//                   actionLabel,
//                   style: const TextStyle(
//                     color: AppColors.primaryBlue,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   Widget _infoRow(
//       String label,
//       String? value, {
//         bool multiline = false,
//       }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         crossAxisAlignment:
//         multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 130,
//             child: Text(
//               label,
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               (value == null || value.isEmpty) ? '-' : value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.navy,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
