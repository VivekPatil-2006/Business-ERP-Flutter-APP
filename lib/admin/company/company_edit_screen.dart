import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/company_service.dart';

class CompanyEditScreen extends StatefulWidget {
  const CompanyEditScreen({super.key});

  @override
  State<CompanyEditScreen> createState() => _CompanyEditScreenState();
}

class _CompanyEditScreenState extends State<CompanyEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // ───────── Controllers ─────────
  final companyNameCtrl = TextEditingController();
  final tinCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final contactPersonCtrl = TextEditingController();
  final contactEmailCtrl = TextEditingController();
  final contactPhoneCtrl = TextEditingController();
  final termsCtrl = TextEditingController();

  String? logoBase64;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final snap = await CompanyService().getCompany().first;
    final data = snap.data();
    if (data == null) return;

    companyNameCtrl.text = data['companyName'] ?? '';
    tinCtrl.text = data['companyTIN'] ?? '';
    websiteCtrl.text = data['companyWebsite'] ?? '';
    addressCtrl.text = data['address'] ?? '';
    contactPersonCtrl.text = data['contactPerson'] ?? '';
    contactEmailCtrl.text = data['contactEmail'] ?? '';
    contactPhoneCtrl.text = data['contactPhone'] ?? '';
    termsCtrl.text = data['generalTermsAndConditions'] ?? '';
    logoBase64 = data['logoImage'];

    setState(() => isLoading = false);
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    await CompanyService().updateCompany({
      'companyName': companyNameCtrl.text.trim(),
      'companyTIN': tinCtrl.text.trim(),
      'companyWebsite': websiteCtrl.text.trim(),
      'address': addressCtrl.text.trim(),
      'contactPerson': contactPersonCtrl.text.trim(),
      'contactEmail': contactEmailCtrl.text.trim(),
      'contactPhone': contactPhoneCtrl.text.trim(),
      'generalTermsAndConditions': termsCtrl.text.trim(),
      'logoImage': logoBase64,
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() => logoBase64 = base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading company details...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Edit Company Information',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🖼️ COMPANY LOGO (TOP)
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
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
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: logoBase64 != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(
                            base64Decode(logoBase64!),
                            fit: BoxFit.contain,
                          ),
                        )
                            : const Icon(
                          Icons.business,
                          size: 48,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tap to change company logo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🏢 COMPANY DETAILS
              _section(
                'Company Details',
                [
                  AppTextField(
                    controller: companyNameCtrl,
                    label: 'Company Name',
                    validator: _required,
                  ),
                  AppTextField(controller: tinCtrl, label: 'TIN / GST'),
                  AppTextField(controller: websiteCtrl, label: 'Website'),
                  AppTextField(controller: addressCtrl, label: 'Address'),
                  AppTextField(
                    controller: contactPersonCtrl,
                    label: 'Contact Person',
                    validator: _required,
                  ),
                  AppTextField(
                    controller: contactEmailCtrl,
                    label: 'Contact Email',
                    validator: _required,
                  ),
                  AppTextField(
                    controller: contactPhoneCtrl,
                    label: 'Contact Phone',
                    validator: _required,
                  ),
                  AppTextField(
                    controller: termsCtrl,
                    label: 'Terms & Conditions',
                  ),
                ],
              ),

              const SizedBox(height: 30),

              AppButton(
                label: 'Save Company Info',
                isLoading: isLoading,
                onPressed: _saveCompany,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(22),
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
          const SizedBox(height: 12),
          ...children.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: e,
            ),
          ),
        ],
      ),
    );
  }

  String? _required(String? v) =>
      v == null || v.isEmpty ? 'Required' : null;
}
