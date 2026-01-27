import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../shared/widgets/admin_drawer.dart';

import 'sections/enquiry_analytics_section.dart';
import 'sections/quotation_analytics_section.dart';
import 'sections/payment_analytics_section.dart';
import 'sections/invoice_analytics_section.dart';
import 'sections/client_movement_section.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/adminDashboard'),
      backgroundColor: AppColors.lightGrey,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          // 🔹 Enquiries
          EnquiryAnalyticsSection(),
          SizedBox(height: 24),

          // 🔹 Quotations
          QuotationAnalyticsSection(),
          SizedBox(height: 24),

          // 🔹 Payments
          PaymentAnalyticsSection(),
          SizedBox(height: 24),

          // 🔹 Invoices
          InvoiceAnalyticsSection(),
          SizedBox(height: 24),

          // 🔹 Client Movement Alerts
          ClientMovementSection(),
        ],
      ),
    );
  }
}
