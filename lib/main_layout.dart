//import 'package:dealtrack/sales_manager/enquiries/sales_enquiry_list_screen.dart';

import 'sales_manager/clients/client_list_screen.dart';
import 'sales_manager/dashboard/sales_dashboard.dart';
import 'sales_manager/enquiries/create_enquiry_screen.dart';
import 'sales_manager/invoices/invoice_home_screen.dart';
import 'sales_manager/loi/loi_ack_screen.dart';
import 'sales_manager/payments/payment_list_screen.dart';
import 'sales_manager/profile/sales_profile_screen.dart';
import 'sales_manager/quotations/create_quotation_screen.dart';
import 'sales_manager/enquiries/sales_enquiry_list_screen.dart';
import 'sales_manager/quotations/quotation_list_sales.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'client/enquiries/client_enquiry_list_screen.dart';
import 'client/invoices/client_invoice_list_screen.dart';
import 'client/notifications/notification_list_screen.dart';
import 'client/payments/client_payment_screen.dart';
import 'client/profile/client_profile_screen.dart';
import 'client/quotations/client_quotation_list_screen.dart';
import 'core/theme/app_colors.dart';
import 'core/services/auth_service.dart';

// import 'comman/login_screen.dart';

// // SALES MANAGER
import 'sales_manager/dashboard/sales_dashboard.dart';
// import '../client/client_list_screen.dart';
// import '../enquiry/create_enquiry_screen.dart';
// import '../quotation/create_quotation_screen.dart';
// import '../loi/loi_ack_screen.dart';
// import '../profile/sales_profile_screen.dart';
// import '../payment/payment_list_screen.dart';
//
// // CLIENT
import 'client/dashboard/client_dashboard.dart';
// import '../client/client_profile_screen.dart';
// import '../client/client_enquiry_list_screen.dart';
// import '../client/create_client_enquiry_screen.dart';
// import '../client/client_quotation_list_screen.dart';
// import '../payment/client_payment_screen.dart';
//
// // COMMON
// import '../invoice/invoice_home_screen.dart';
// import '../notification/notification_list_screen.dart';

import 'auth/login/admin_login_screen.dart';

class MainLayout extends StatefulWidget {
  final String role;

  const MainLayout({super.key, required this.role});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  String get uid => auth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {

    final Widget homeScreen =
    widget.role == "sales_manager"
        ? const SalesDashboard()
        : const ClientDashboard();

    return Scaffold(

      appBar: AppBar(
        backgroundColor: AppColors.darkBlue, // navy blue
        foregroundColor: Colors.white,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white, // drawer/back icon color
        ),

        title: Text(
          widget.role.toUpperCase(), // CLIENT / SALES_MANAGER
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      drawer: Drawer(
        backgroundColor: AppColors.darkBlue,

        child: Column(
          children: [

            // ================= PROFILE HEADER =================
            buildProfileHeader(),

            // ================= DASHBOARD =================
            buildMenuTile(
              "Dashboard",
              Icons.dashboard,
                  () => Navigator.pop(context),
            ),

            // ====================================================
            // ================= SALES MANAGER MENU ==============
            // ====================================================

            if (widget.role == "sales_manager") ...[

              buildMenuTile(
                "Clients",
                Icons.people,
                    () => push(const ClientListScreen()),
              ),

              buildMenuTile(
                "Enquiry",
                Icons.description,
                    () => push(const SalesEnquiryListScreen()),
              ),

              // buildMenuTile(
              //   "Create Enquiry",
              //   Icons.assignment_add,
              //       () => push(const CreateEnquiryScreen()),
              // ),

              // buildMenuTile(
              //   "Send Quotation",
              //   Icons.description,
              //       () => push(const CreateQuotationScreen()),
              // ),
              buildMenuTile(
                "Quotation",
                  Icons.description,
                    () => push(const QuotationListSales()),
              ),

              buildMenuTile(
                "LOI Approvals",
                Icons.verified,
                    () => push(const LoiAckScreen()),
              ),

              // buildMenuTile(
              //   "Payments",
              //   Icons.payment,
              //       () => push(const PaymentListScreen()),
              // ),

              buildMenuTile(
                "Invoices",
                Icons.receipt_long,
                    () => push(const InvoiceHomeScreen()),
              ),

              buildMenuTile(
                "Notifications",
                Icons.notifications,
                    () => push(NotificationListScreen(userId: uid)),
              ),


            ],

            // ====================================================
            // ================= CLIENT MENU =====================
            // ====================================================

            if (widget.role == "client") ...[

              buildMenuTile(
                "Enquiries",
                Icons.assignment,
                    () => push(const ClientEnquiryListScreen()),
              ),

              buildMenuTile(
                "Quotations",
                Icons.description,
                    () => push(const ClientQuotationListScreen()),
              ),


              buildMenuTile(
                "Payments",
                Icons.payment,
                    () => push(const ClientPaymentScreen()),
              ),

              buildMenuTile(
                "My Invoices",
                Icons.receipt_long,
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ClientInvoiceListScreen(),
                    ),
                  );
                },
              ),

              buildMenuTile(
                "Notifications",
                Icons.notifications,
                    () => push(NotificationListScreen(userId: uid)),
              ),

            ],

            const Spacer(),

            // ================= LOGOUT =================

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: logout,
            ),
          ],
        ),
      ),

      body: homeScreen,
    );
  }

  // ====================================================
  // ================= PROFILE HEADER ===================
  // ====================================================

  Widget buildProfileHeader() {

    // ================= CLIENT HEADER =================

    if (widget.role == "client") {

      return FutureBuilder<DocumentSnapshot>(
        future: firestore.collection("clients").doc(uid).get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const DrawerHeader(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          final companyName = data?['companyName'] ?? "Client";
          final imageUrl = data?['profileImage'] ?? "";
          final email =
              data?['emailAddress'] ??
                  auth.currentUser?.email ??
                  "";

          return DrawerHeader(
            child: GestureDetector(
              onTap: () => push(ClientProfileScreen(clientId: uid)),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.business,
                        color: Colors.white, size: 30)
                        : null,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    companyName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    email,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // ================= SALES MANAGER HEADER =================

    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection("sales_managers").doc(uid).get(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const DrawerHeader(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final name = data?['name'] ?? "Sales Manager";
        final imageUrl = data?['profileImage'] ?? "";
        final email = auth.currentUser?.email ?? "";

        return DrawerHeader(
          child: GestureDetector(
            onTap: () => push(const SalesProfileScreen()),

            child: Column(
              children: [

                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white24,
                  backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person,
                      color: Colors.white, size: 30)
                      : null,
                ),

                const SizedBox(height: 10),

                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  email,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ====================================================
  // ================= HELPERS ==========================
  // ====================================================

  void push(Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
          (_) => false,
    );
  }

  Widget buildMenuTile(
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neonBlue),
      title: Text(title,
          style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
