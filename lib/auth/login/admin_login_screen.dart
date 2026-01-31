import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../register/admin_register_screen.dart';
import '../../core/theme/app_colors.dart';

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


  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // 🔐 Firebase Authentication
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final uid = cred.user!.uid;
      final db = FirebaseFirestore.instance;

      // 🧠 ROLE DETECTION (PRIORITY ORDER)

      // ADMIN
      final adminDoc = await db.collection('admin').doc(uid).get();
      if (adminDoc.exists) {
        Navigator.pushReplacementNamed(context, '/adminDashboard');
        return;
      }

      // SALES MANAGER
      final managerDoc =
      await db.collection('sales_managers').doc(uid).get();
      if (managerDoc.exists) {
        Navigator.pushReplacementNamed(context, '/salesManagerDashboard');
        return;
      }

      // CLIENT
      final clientDoc = await db.collection('clients').doc(uid).get();
      if (clientDoc.exists) {
        Navigator.pushReplacementNamed(context, '/clientDashboard');
        return;
      }

      // ❌ NO ROLE FOUND
      await FirebaseAuth.instance.signOut();
      throw Exception('User role not assigned. Contact admin.');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🤖 AI BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/ai/ai_pattern.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🌫 OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.92),
            ),
          ),

          // 🔐 LOGIN CARD
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
                      // 🧠 LOGO + TITLE
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
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonBlue.withOpacity(0.45),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
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
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Admin • Sales Manager • Client',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 34),

                      // 📧 EMAIL
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

                      // 🔐 PASSWORD
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
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) =>
                        v!.isEmpty ? 'Enter password' : null,
                      ),


                      const SizedBox(height: 30),

                      // 🔵 LOGIN BUTTON
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF2979FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 10,
                          ),
                          child: isLoading
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
                      const SizedBox(height: 12),

// 🆕 REGISTER BUTTON
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminRegisterScreen(),
                              ),
                            );
                          },

                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF2979FF),
                              width: 1.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'REGISTER',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: Color(0xFF2979FF),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),


                      // 🔁 FORGOT PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            FirebaseAuth.instance
                                .sendPasswordResetEmail(
                              email: emailCtrl.text.trim(),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password reset email sent',
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF2979FF),
                              fontWeight: FontWeight.w600,
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

  // ✨ COMMON INPUT DECORATION
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