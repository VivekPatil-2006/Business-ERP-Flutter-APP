import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main_layout.dart';
import '../register/admin_register_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  // =========================
  // LOGIN
  // =========================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // 1️⃣ Firebase Authentication
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final user = cred.user;
      if (user == null) {
        throw Exception('Login failed');
      }

      // 2️⃣ Get Firebase ID token
      final token = await user.getIdToken(true);

      // 3️⃣ Verify login with backend
      final response = await ApiService.postPublic(
        "/auth/login",
        {"token": token},
      );

      if (!mounted) return;

      // 4️⃣ ROLE FROM BACKEND (DECIDED BY TABLE MATCHING)
      final role = response['user']?['role'];

      if (role == null) {
        throw Exception('Role not found');
      }

      // 5️⃣ ROUTE BASED ON ROLE
      switch (role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, '/clients');
          break;

        case 'sales_manager':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainLayout(role: 'sales_manager'),
            ),
          );
          break;

        case 'client':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MainLayout(role: 'client'),
            ),
          );
          break;

        default:
          throw Exception('Unknown role: $role');
      }
    } catch (e) {
      // 🔐 Clean logout on failure
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🤖 Background
          Positioned.fill(
            child: Image.asset(
              'assets/ai/ai_pattern.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.92),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: 420,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.25),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HEADER
                      Column(
                        children: [
                          Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.neonBlue,
                                width: 2.2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo/logo.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'ERP System',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Login',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 34),

                      // EMAIL
                      TextFormField(
                        controller: emailCtrl,
                        decoration: _inputDecoration(
                          label: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        validator: (v) =>
                        v == null || v.isEmpty ? 'Enter email' : null,
                      ),

                      const SizedBox(height: 16),

                      // PASSWORD
                      TextFormField(
                        controller: passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          label: 'Password',
                          icon: Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) =>
                        v == null || v.isEmpty ? 'Enter password' : null,
                      ),

                      const SizedBox(height: 30),

                      // LOGIN BUTTON
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2979FF),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // REGISTER (ADMIN ONLY)
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminRegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('REGISTER'),
                      ),

                      const SizedBox(height: 12),

                      // FORGOT PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(
                              email: emailCtrl.text.trim(),
                            );

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                Text('Password reset email sent'),
                              ),
                            );
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
