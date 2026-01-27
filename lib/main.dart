import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

// ================= AUTH =================
import 'auth/login/admin_login_screen.dart';
import 'auth/register/admin_register_screen.dart';

// ================= ADMIN =================
import 'admin/dashboard/admin_dashboard_screen.dart';

// Sales Managers
import 'admin/sales_managers/sales_manager_list_screen.dart';
import 'admin/sales_managers/sales_manager_create_screen.dart';

// Clients
import 'admin/clients/client_list_screen.dart';
import 'admin/clients/client_create_screen.dart';

//Company Profile
import 'admin/company/company_profile_screen.dart';

// ================= CORE =================
import 'core/guards/admin_auth_guard.dart';

import 'admin/products/product_list_screen.dart';
import 'admin/products/product_create_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DealTrackApp());
}

class DealTrackApp extends StatelessWidget {
  const DealTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deal Track',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.23, // 🔥 increase all fonts
          ),
          child: child!,
        );
      },


      // 🔑 App Entry
      initialRoute: '/login',

      routes: {
        // ================= AUTH =================
        '/login': (context) => const AdminLoginScreen(),
        '/register': (context) => const AdminRegisterScreen(),

        // ================= ADMIN DASHBOARD =================
        '/adminDashboard': (context) => const AdminAuthGuard(
          child: AdminDashboardScreen(),
        ),

        // ================= SALES MANAGERS =================
        '/salesManagers': (context) => const AdminAuthGuard(
          child: SalesManagerListScreen(),
        ),

        '/createSalesManager': (context) => const AdminAuthGuard(
          child: SalesManagerCreateScreen(),
        ),

        // ================= CLIENTS =================
        '/clients': (context) => const AdminAuthGuard(
          child: ClientListScreen(),
        ),

        '/createClient': (context) => const AdminAuthGuard(
          child: ClientCreateScreen(),
        ),

        '/companyProfile': (context) => const AdminAuthGuard(
          child: CompanyProfileScreen(),
        ),

        '/products': (context) => const AdminAuthGuard(
          child: ProductListScreen(),
        ),

        '/createProduct': (context) => const AdminAuthGuard(
          child: ProductCreateScreen(),
        ),

        // ================= NOTIFICATIONS =================
        '/notifications': (context) => const AdminAuthGuard(
          child: Placeholder(),
        ),
      },
    );
  }
}
