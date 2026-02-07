import 'package:dealtrackuser/sales_manager/dashboard/sales_dashboard.dart';
import 'package:dealtrackuser/sales_manager/invoices/invoice_home_screen.dart';
import 'package:dealtrackuser/sales_manager/loi/loi_ack_screen.dart';
import 'package:dealtrackuser/sales_manager/quotations/quotation_list_sales.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'admin/clients/client_list_screen.dart';
import 'core/theme/app_colors.dart';
import 'core/services/auth_service.dart';

// ================= SALES MANAGER =================
import 'sales_manager/enquiries/sales_enquiry_list_screen.dart';
import 'sales_manager/clients/client_list_screen.dart';
// import 'sales_manager/clients/client_list_screen.dart';
// import 'sales_manager/quotations/quotation_list_sales.dart';
// import 'sales_manager/loi/loi_ack_screen.dart';
// import 'sales_manager/invoices/invoice_home_screen.dart';
// import 'sales_manager/profile/sales_profile_screen.dart';

// ================= CLIENT =================
import 'client/enquiries/client_enquiry_list_screen.dart';
// import 'client/quotations/client_quotation_list_screen.dart';
// import 'client/payments/client_payment_screen.dart';
// import 'client/invoices/client_invoice_list_screen.dart';
// import 'client/notifications/notification_list_screen.dart';
// import 'client/profile/client_profile_screen.dart';

// ================= AUTH =================
import 'auth/login/admin_login_screen.dart';

class MainLayout extends StatefulWidget {
  final String role; // "sales_manager" | "client"

  const MainLayout({
    super.key,
    required this.role,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // ================= HOME SCREEN =================
    late final Widget homeScreen;

    if (widget.role == 'sales_manager') {
      homeScreen = const SalesDashboard();
    } else {
      homeScreen = const ClientEnquiryListScreen();
    }

    return Scaffold(
      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,

        // ✅ ENSURE DRAWER ICON APPEARS
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        title: Text(
          widget.role == 'sales_manager'
              ? 'Sales Manager'
              : 'Client',
        ),
      ),

      body: homeScreen,
    );
  }

  // =====================================================
  // ================= DRAWER ============================
  // =====================================================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.darkBlue,
      child: Column(
        children: [
          _buildProfileHeader(),

          // ================= SALES MANAGER MENU =================
          if (widget.role == 'sales_manager') ...[
            _menuTile(
              'DashBoard',
              // Icons.assignment,
              //     () => Navigator.pop(context),
              Icons.people,
                  () => _push(const SalesDashboard()),
            ),

            _menuTile(
              'Clients',
              Icons.people,
                  () => _push(const ClientListScreen()),
            ),
            _menuTile(
              'Enquiries',
              Icons.people,
                  () => _push(const SalesEnquiryListScreen()),
            ),

            _menuTile(
              'Quotations',
              Icons.description,
                  () => _push(const QuotationListSales()),
            ),

            _menuTile(
              'LOI Approvals',
              Icons.verified,
                  () => _push(const LoiAckScreen()),
            ),

            _menuTile(
              'Invoices',
              Icons.receipt_long,
                  () => _push(const InvoiceHomeScreen()),
            ),

            // _menuTile(
            //   'Profile',
            //   Icons.person,
            //       () => _push(const SalesProfileScreen()),
            // ),

          ],

          // ================= CLIENT MENU =================
          if (widget.role == 'client') ...[
            _menuTile(
              'Enquiries',
              Icons.assignment,
                  () => Navigator.pop(context),
            ),

            /*
            FUTURE CLIENT MENU
            ------------------
            _menuTile(
              'Quotations',
              Icons.description,
              () => _push(const ClientQuotationListScreen()),
            ),

            _menuTile(
              'Payments',
              Icons.payment,
              () => _push(const ClientPaymentScreen()),
            ),
            _menuTile(
              'Invoices',
              Icons.receipt_long,
              () => _push(const ClientInvoiceListScreen()),
            ),
            _menuTile(
              'Notifications',
              Icons.notifications,
              () => _push(NotificationListScreen(userId: uid)),
            ),
            _menuTile(
              'Profile',
              Icons.person,
              () => _push(ClientProfileScreen(clientId: uid)),
            ),
            */
          ],

          const Spacer(),

          // ================= LOGOUT =================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ================= PROFILE HEADER ====================
  // =====================================================

  Widget _buildProfileHeader() {
    final email = auth.currentUser?.email ?? '';

    return DrawerHeader(
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white24,
            child: Icon(
              widget.role == 'sales_manager'
                  ? Icons.person
                  : Icons.business,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.role == 'sales_manager'
                ? 'Sales Manager'
                : 'Client',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ================= HELPERS ===========================
  // =====================================================

  void _push(Widget page) {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
          (_) => false,
    );
  }

  Widget _menuTile(
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neonBlue),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}
