import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';

// ================= AUTH =================
import 'auth/login/admin_login_screen.dart';
import 'auth/register/admin_register_screen.dart';

// ================= ADMIN =================
import 'admin/dashboard/admin_dashboard_screen.dart';
import 'admin/sales_managers/sales_manager_list_screen.dart';
import 'admin/sales_managers/sales_manager_create_screen.dart';
import 'admin/clients/client_list_screen.dart';
import 'admin/clients/client_create_screen.dart';
import 'admin/company/company_profile_screen.dart';
import 'admin/products/product_list_screen.dart';
import 'admin/products/product_create_screen.dart';

// ================= SALES + CLIENT =================
// import 'main_layout.dart';



// ================= SALES =================
import 'sales_manager/enquiries/sales_enquiry_list_screen.dart';


// ================= CLIENT =================
import 'client/enquiries/client_enquiry_list_screen.dart';



// ================= CORE =================
import 'core/guards/admin_auth_guard.dart';

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
      builder: (context, child){
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.22),
          child: child!,
        );
        child: child!;
      },

      // 🔑 SINGLE ENTRY POINT
      initialRoute: '/login',

      routes: {
        // ================= AUTH =================
        '/login': (_) => const AdminLoginScreen(),
        '/register': (_) => const AdminRegisterScreen(),

        // ================= ADMIN =================
        // '/adminDashboard': (_) => const AdminAuthGuard(
        //   child: AdminDashboardScreen(),
        // ),

        '/salesManagers': (_) => const AdminAuthGuard(
          child: SalesManagerListScreen(),
        ),
        '/createSalesManager': (_) => const AdminAuthGuard(
          child: SalesManagerCreateScreen(),
        ),

        '/clients': (_) => const AdminAuthGuard(
          child: ClientListScreen(),
        ),
        '/createClient': (_) => const AdminAuthGuard(
          child: ClientCreateScreen(),
        ),

        '/companyProfile': (_) => const AdminAuthGuard(
          child: CompanyProfileScreen(),
        ),

        '/products': (_) => const AdminAuthGuard(
          child: ProductListScreen(),
        ),
        '/createProduct': (_) => const AdminAuthGuard(
          child: ProductCreateScreen(),
        ),

        // ================= SALES MANAGER =================
        '/sales_manager/enquiries': (_) =>
        const SalesEnquiryListScreen(),

        // ================= CLIENT =================
        '/client/enquiries': (_) =>
        const ClientEnquiryListScreen(),
      },
    );
  }
}
