import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'invoice_list_screen.dart';
import 'create_invoice_screen.dart';

class InvoiceHomeScreen extends StatelessWidget {
  const InvoiceHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Invoices"),
      ),

      // ======================
      // INVOICE LIST BODY
      // ======================

      body: const InvoiceListScreen(),

      // ======================
      // CREATE BUTTON
      // ======================

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.primaryBlue,
      //
      //   child: const Icon(Icons.add),
      //
      //   onPressed: () {
      //
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (_) => const CreateInvoiceScreen(),
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
