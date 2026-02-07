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

  Future<void> _loadBankData() async {
    final data = await CompanyService().getCompany();
    final bank = data['bankDetails'] ?? {};

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

  Future<void> _pickQr() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
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
        title: const Text('Edit Bank Details'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _section('Bank Information', [
                AppTextField(
                  controller: bankNameCtrl,
                  label: 'Bank Name',
                  validator: _required,
                ),
                AppTextField(controller: branchCtrl, label: 'Branch Name'),
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
                AppTextField(controller: ifscCtrl, label: 'IFSC Code'),
                AppTextField(controller: upiCtrl, label: 'UPI ID'),
                DropdownButtonFormField<String>(
                  value: accountType,
                  decoration: const InputDecoration(labelText: 'Account Type'),
                  items: const [
                    DropdownMenuItem(value: 'saving', child: Text('Saving')),
                    DropdownMenuItem(value: 'current', child: Text('Current')),
                  ],
                  onChanged: (v) => setState(() => accountType = v!),
                ),
              ]),
              const SizedBox(height: 20),
              _section('QR / Scanner Image', [
                _imagePickerRow(
                  label: 'UPI QR Code',
                  base64: qrBase64,
                  onPick: _pickQr,
                ),
              ]),
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

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.navy)),
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
      children: [
        SizedBox(width: 140, child: Text(label)),
        Expanded(
          child: InkWell(
            onTap: onPick,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: base64 != null
                  ? Image.memory(base64Decode(base64))
                  : const Center(child: Text('Tap to upload QR')),
            ),
          ),
        ),
      ],
    );
  }

  String? _required(String? v) => v == null || v.isEmpty ? 'Required' : null;
}
