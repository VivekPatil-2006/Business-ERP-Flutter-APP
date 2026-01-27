import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/company_service.dart';

class BankEditScreen extends StatefulWidget {
  const BankEditScreen({super.key});

  @override
  State<BankEditScreen> createState() => _BankEditScreenState();
}

class _BankEditScreenState extends State<BankEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // ───────── Controllers ─────────
  final bankNameCtrl = TextEditingController();
  final branchCtrl = TextEditingController();
  final accountHolderCtrl = TextEditingController();
  final accountNoCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final upiCtrl = TextEditingController();

  String accountType = 'saving';
  String? qrBase64;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBankData();
  }

  // ================= LOAD =================
  Future<void> _loadBankData() async {
    final snap = await CompanyService().getCompany().first;
    final bank = snap.data()?['bankDetails'] ?? {};

    bankNameCtrl.text = bank['bankName'] ?? '';
    branchCtrl.text = bank['branchName'] ?? '';
    accountHolderCtrl.text = bank['accountHolderName'] ?? '';
    accountNoCtrl.text = bank['bankAccountNumber'] ?? '';
    ifscCtrl.text = bank['ifscCode'] ?? '';
    upiCtrl.text = bank['upiId'] ?? '';
    accountType = bank['accountType'] ?? 'saving';
    qrBase64 = bank['scannerImage'];

    setState(() => isLoading = false);
  }

  // ================= SAVE =================
  Future<void> _saveBank() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    await CompanyService().updateCompany({
      'bankDetails': {
        'bankName': bankNameCtrl.text.trim(),
        'branchName': branchCtrl.text.trim(),
        'accountHolderName': accountHolderCtrl.text.trim(),
        'bankAccountNumber': accountNoCtrl.text.trim(),
        'ifscCode': ifscCtrl.text.trim(),
        'upiId': upiCtrl.text.trim(),
        'accountType': accountType,
        'scannerImage': qrBase64,
      },
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  // ================= IMAGE PICKER =================
  Future<void> _pickQr() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() => qrBase64 = base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading bank details...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Edit Bank Details',
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
              // 🏦 BANK INFO
              _section(
                'Bank Information',
                [
                  AppTextField(
                    controller: bankNameCtrl,
                    label: 'Bank Name',
                    validator: _required,
                  ),
                  AppTextField(
                    controller: branchCtrl,
                    label: 'Branch Name',
                  ),
                  AppTextField(
                    controller: accountHolderCtrl,
                    label: 'Account Holder Name',
                    validator: _required,
                  ),
                  AppTextField(
                    controller: accountNoCtrl,
                    label: 'Account Number',
                    keyboardType: TextInputType.number,
                    validator: _required,
                  ),
                  AppTextField(
                    controller: ifscCtrl,
                    label: 'IFSC Code',
                  ),
                  AppTextField(
                    controller: upiCtrl,
                    label: 'UPI ID',
                  ),
                  DropdownButtonFormField<String>(
                    value: accountType,
                    decoration: const InputDecoration(
                      labelText: 'Account Type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'saving',
                        child: Text('Saving'),
                      ),
                      DropdownMenuItem(
                        value: 'current',
                        child: Text('Current'),
                      ),
                    ],
                    onChanged: (v) => setState(() => accountType = v!),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📷 QR IMAGE
              _section(
                'QR / Scanner Image',
                [
                  _imagePickerRow(
                    label: 'UPI QR Code',
                    base64: qrBase64,
                    onPick: _pickQr,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              AppButton(
                label: 'Save Bank Details',
                isLoading: isLoading,
                onPressed: _saveBank,
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
          const SizedBox(height: 14),
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

  Widget _imagePickerRow({
    required String label,
    required String? base64,
    required VoidCallback onPick,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          child: Material(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onPick,
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(10),
                child: base64 != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    base64Decode(base64),
                    fit: BoxFit.contain,
                  ),
                )
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: AppColors.primaryBlue,
                        size: 32,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Tap to upload QR',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _required(String? v) =>
      v == null || v.isEmpty ? 'Required' : null;
}
