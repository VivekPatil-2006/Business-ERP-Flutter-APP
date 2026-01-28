import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'comman/login_screen.dart';
import 'core/theme/app_colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.lightGrey,
        primaryColor: AppColors.primaryBlue,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
        ),
      ),
      builder: (context,child){
        return MediaQuery(data:MediaQuery.of(context).copyWith(textScaleFactor: 1.21),
            child:child!,
        );
      },
      home: const LoginScreen(),
    );


  }
}
