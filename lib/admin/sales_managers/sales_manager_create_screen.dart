import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import 'services/sales_manager_service.dart';

class SalesManagerCreateScreen extends StatefulWidget {
  const SalesManagerCreateScreen({super.key});

  @override
  State<SalesManagerCreateScreen> createState() =>
      _SalesManagerCreateScreenState();
}

class _SalesManagerCreateScreenState extends State<SalesManagerCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // ───────── Personal Info ─────────
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  String gender = 'Male';

  // ───────── Address Info ─────────
  final address1Ctrl = TextEditingController();
  final address2Ctrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final postcodeCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> _createSalesManager() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await SalesManagerService().createSalesManager(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        gender: gender,
        dob: dobCtrl.text.trim(),
        addressLine1: address1Ctrl.text.trim(),
        addressLine2: address2Ctrl.text.trim(),
        state: stateCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        postcode: postcodeCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sales Manager created successfully.\nPassword reset email sent.',
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/salesManagers',
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Create Sales Manager',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.navy,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _sectionCard(
                title: 'Personal Information',
                children: [
                  AppTextField(
                    controller: nameCtrl,
                    label: 'Full Name',
                    validator: _required,
                  ),
                  AppTextField(
                    controller: emailCtrl,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _required,
                  ),
                  AppTextField(
                    controller: phoneCtrl,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                    validator: _required,
                  ),
                  AppTextField(
                    controller: dobCtrl,
                    label: 'Date of Birth',
                   // hint: 'DD/MM/YYYY',
                  ),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: _dropdownDecoration('Gender'),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (v) => gender = v!,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _sectionCard(
                title: 'Address Information',
                children: [
                  AppTextField(
                    controller: address1Ctrl,
                    label: 'Address Line 1',
                  ),
                  AppTextField(
                    controller: address2Ctrl,
                    label: 'Address Line 2',
                  ),
                  AppTextField(
                    controller: cityCtrl,
                    label: 'City',
                  ),
                  AppTextField(
                    controller: stateCtrl,
                    label: 'State',
                  ),
                  AppTextField(
                    controller: postcodeCtrl,
                    label: 'Postcode',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              AppButton(
                label: 'Create Sales Manager',
                isLoading: isLoading,
                onPressed: _createSalesManager,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────── UI HELPERS ─────────

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 16),
          ...children.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: e,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  String? _required(String? v) => v == null || v.isEmpty ? 'Required' : null;
}
