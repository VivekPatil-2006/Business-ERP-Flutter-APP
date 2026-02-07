import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import 'services/client_service.dart';

class ClientCreateScreen extends StatefulWidget {
  const ClientCreateScreen({super.key});

  @override
  State<ClientCreateScreen> createState() => _ClientCreateScreenState();
}

class _ClientCreateScreenState extends State<ClientCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // ───────── Company & Identity ─────────
  final companyNameCtrl = TextEditingController();
  final customerCodeCtrl = TextEditingController();
  final ssnCtrl = TextEditingController();
  final einCtrl = TextEditingController();
  final vatCtrl = TextEditingController();

  // ───────── Personal / Contact ─────────
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final contactPersonCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phone1Ctrl = TextEditingController();
  final phone2Ctrl = TextEditingController();
  final cellphoneCtrl = TextEditingController();
  final faxCtrl = TextEditingController();

  // ───────── Address ─────────
  final countryCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final postcodeCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> _createClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await ClientService().createClient(
        companyName: companyNameCtrl.text.trim(),
        customerCode: customerCodeCtrl.text.trim(),
        socialSecurityNumber: ssnCtrl.text.trim(),
        einTin: einCtrl.text.trim(),
        vatIdentifier: vatCtrl.text.trim(),
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        contactPerson: contactPersonCtrl.text.trim(),
        emailAddress: emailCtrl.text.trim(),
        phoneNo1: phone1Ctrl.text.trim(),
        phoneNo2: phone2Ctrl.text.trim(),
        cellphone: cellphoneCtrl.text.trim(),
        faxNo: faxCtrl.text.trim(),
        country: countryCtrl.text.trim(),
        street: streetCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        postcode: postcodeCtrl.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/clients',
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Create Client',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _card('Company & Identity', [
                AppTextField(
                  controller: companyNameCtrl,
                  label: 'Company Name',
                  validator: _required,
                ),
                AppTextField(
                    controller: customerCodeCtrl,
                    label: 'Customer Code'),
                AppTextField(
                    controller: ssnCtrl,
                    label: 'Social Security Number'),
                AppTextField(
                    controller: einCtrl,
                    label: 'EIN / TIN'),
                AppTextField(
                    controller: vatCtrl,
                    label: 'VAT Identifier'),
              ]),

              const SizedBox(height: 20),

              _card('Personal & Contact Details', [
                AppTextField(
                    controller: firstNameCtrl,
                    label: 'First Name'),
                AppTextField(
                    controller: lastNameCtrl,
                    label: 'Last Name'),
                AppTextField(
                  controller: contactPersonCtrl,
                  label: 'Contact Person',
                  validator: _required,
                ),
                AppTextField(
                  controller: emailCtrl,
                  label: 'Email Address',
                  validator: _required,
                ),
                AppTextField(
                    controller: phone1Ctrl,
                    label: 'Phone No 1'),
                AppTextField(
                    controller: phone2Ctrl,
                    label: 'Phone No 2'),
                AppTextField(
                    controller: cellphoneCtrl,
                    label: 'Cellphone'),
                AppTextField(
                    controller: faxCtrl,
                    label: 'Fax No'),
              ]),

              const SizedBox(height: 20),

              _card('Address Details', [
                AppTextField(
                    controller: countryCtrl,
                    label: 'Country'),
                AppTextField(
                    controller: streetCtrl,
                    label: 'Street'),
                AppTextField(
                    controller: cityCtrl,
                    label: 'City'),
                AppTextField(
                    controller: stateCtrl,
                    label: 'State'),
                AppTextField(
                    controller: postcodeCtrl,
                    label: 'Postcode'),
              ]),

              const SizedBox(height: 30),

              AppButton(
                label: 'Create Client',
                isLoading: isLoading,
                onPressed: _createClient,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────── UI HELPERS ─────────

  Widget _card(String title, List<Widget> children) {
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
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
              fontSize: 16,
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

  String? _required(String? v) =>
      v == null || v.isEmpty ? 'Required' : null;
}
