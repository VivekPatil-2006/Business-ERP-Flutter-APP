import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthGuard extends StatelessWidget {
  final Widget child;

  const AdminAuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⬜ While auth state is resolving
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _blank();
        }

        // ❌ Not logged in
        if (!snapshot.hasData) {
          return _blank();
        }

        // ✅ Logged in → allow access
        return child;
      },
    );
  }

  Widget _blank() {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(),
    );
  }
}
