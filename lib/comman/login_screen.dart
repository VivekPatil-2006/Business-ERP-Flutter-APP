import 'package:flutter/material.dart';

import '../core/services/auth_service.dart';
import '../core/services/firestore_service.dart';
import '../core/theme/app_colors.dart';
import '../main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;

  login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user =
      await AuthService().login(emailCtrl.text.trim(), passCtrl.text.trim());

      final role =
      await FirestoreService().getUserRole(user!.uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainLayout(role: role!),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Stack(
        children: [
          // 🤖 Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/ai/ai_pattern.png',
                fit: BoxFit.cover,
              ),
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.18),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🧠 Logo + Title
                      Column(
                        children: [
                          Container(
                            height: 72,
                            width: 72,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2979FF),
                                  Color(0xFF00E5FF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.4),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/logo/erp_logo.png',
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ERP System',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'User Login',
                            style: TextStyle(
                              color: Colors.grey,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 📧 Email
                      TextFormField(
                        controller: emailCtrl,
                        decoration: _inputDecoration(
                          label: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        validator: (v) =>
                        v!.isEmpty ? 'Enter email' : null,
                      ),

                      const SizedBox(height: 16),

                      // 🔐 Password
                      TextFormField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: _inputDecoration(
                          label: 'Password',
                          icon: Icons.lock_outline,
                        ),
                        validator: (v) =>
                        v!.isEmpty ? 'Enter password' : null,
                      ),

                      const SizedBox(height: 26),

                      // 🔵 Login Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 8,
                            shadowColor:
                            Colors.blueAccent.withOpacity(0.45),
                          ),
                          child: loading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
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

  // ✨ Common Input Decoration
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
