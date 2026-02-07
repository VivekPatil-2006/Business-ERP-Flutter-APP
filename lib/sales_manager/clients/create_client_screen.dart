import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_colors.dart';
import 'services/client_services.dart';

class CreateClientScreen extends StatefulWidget {
  const CreateClientScreen({super.key});

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  // ================================
  // CONTROLLERS
  // ================================

  final companyNameCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  final ssnCtrl = TextEditingController();
  final einCtrl = TextEditingController();
  final vatCtrl = TextEditingController();
  final customerCodeCtrl = TextEditingController();

  final countryCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final postcodeCtrl = TextEditingController();

  final phone1Ctrl = TextEditingController();
  final phone2Ctrl = TextEditingController();
  final cellCtrl = TextEditingController();
  final faxCtrl = TextEditingController();
  final contactPersonCtrl = TextEditingController();

  bool loading = false;

  // ================================
  // CREATE CLIENT (API + RESET EMAIL)
  // ================================

  Future<void> createClient() async {
    if (emailCtrl.text.isEmpty ||
        firstNameCtrl.text.isEmpty ||
        companyNameCtrl.text.isEmpty) {
      _showMsg('Please fill required fields');
      return;
    }

    try {
      setState(() => loading = true);

      // 1️⃣ Create client via backend
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
        cellphone: cellCtrl.text.trim(),
        faxNo: faxCtrl.text.trim(),

        country: countryCtrl.text.trim(),
        street: streetCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        postcode: postcodeCtrl.text.trim(),
      );

      // 2️⃣ Send password reset email via Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailCtrl.text.trim(),
      );

      if (!mounted) return;

      _showMsg(
        'Client created successfully.\nPassword reset link sent to email.',
      );
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      _showMsg(
        e.message ?? 'Failed to send password reset email',
      );
    } catch (e) {
      _showMsg(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================================
  // UI
  // ================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Create Client',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Company Info'),
            input(companyNameCtrl, 'Company Name'),
            input(customerCodeCtrl, 'Customer Code'),

            sectionTitle('Personal Info'),
            input(firstNameCtrl, 'First Name'),
            input(lastNameCtrl, 'Last Name'),
            input(emailCtrl, 'Email Address'),

            sectionTitle('Government IDs'),
            input(ssnCtrl, 'SSN'),
            input(einCtrl, 'EIN / TIN'),
            input(vatCtrl, 'VAT Identifier'),

            sectionTitle('Address'),
            input(countryCtrl, 'Country'),
            input(streetCtrl, 'Street'),
            input(cityCtrl, 'City'),
            input(stateCtrl, 'State'),
            input(postcodeCtrl, 'Postcode'),

            sectionTitle('Contact'),
            input(phone1Ctrl, 'Phone No 1'),
            input(phone2Ctrl, 'Phone No 2'),
            input(cellCtrl, 'Cellphone'),
            input(faxCtrl, 'Fax'),
            input(contactPersonCtrl, 'Contact Person'),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : createClient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'CREATE CLIENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // HELPERS
  // ================================

  Widget input(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  void dispose() {
    companyNameCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();

    ssnCtrl.dispose();
    einCtrl.dispose();
    vatCtrl.dispose();
    customerCodeCtrl.dispose();

    countryCtrl.dispose();
    streetCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    postcodeCtrl.dispose();

    phone1Ctrl.dispose();
    phone2Ctrl.dispose();
    cellCtrl.dispose();
    faxCtrl.dispose();
    contactPersonCtrl.dispose();

    super.dispose();
  }
}
