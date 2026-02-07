import 'package:flutter/material.dart';
import '../../services/admin_auth_service.dart';
import '../../core/theme/app_colors.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final adminNameCtrl = TextEditingController();
  final adminEmailCtrl = TextEditingController();
  final adminPhoneCtrl = TextEditingController();

  final companyNameCtrl = TextEditingController();
  final contactPersonCtrl = TextEditingController();
  final contactEmailCtrl = TextEditingController();
  final contactPhoneCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> _registerAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await AdminAuthService().registerAdminWithCompany(
        adminName: adminNameCtrl.text.trim(),
        adminEmail: adminEmailCtrl.text.trim(),
        adminPhone: adminPhoneCtrl.text.trim(),
        companyName: companyNameCtrl.text.trim(),
        contactPerson: contactPersonCtrl.text.trim(),
        contactEmail: contactEmailCtrl.text.trim(),
        contactPhone: contactPhoneCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company & Admin registered successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔵 Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navy, AppColors.darkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🧠 Subtle Tech Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                'assets/ai/ai_pattern.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonBlue.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 🔷 Header
                      Column(
                        children: const [
                          Text(
                            'Deal Track',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Company & Admin Registration',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      _sectionTitle('Admin Details'),
                      _input(adminNameCtrl, 'Admin Name'),
                      _input(adminEmailCtrl, 'Admin Email'),
                      _input(adminPhoneCtrl, 'Admin Phone'),

                      const SizedBox(height: 24),

                      _sectionTitle('Company Details'),
                      _input(companyNameCtrl, 'Company Name'),
                      _input(contactPersonCtrl, 'Contact Person'),
                      _input(contactEmailCtrl, 'Contact Email'),
                      _input(contactPhoneCtrl, 'Contact Phone'),

                      const SizedBox(height: 32),

                      // 🚀 CTA Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _registerAdmin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 10,
                            shadowColor:
                            AppColors.neonBlue.withOpacity(0.5),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            'REGISTER COMPANY',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.navy,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        validator: (v) => v!.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
