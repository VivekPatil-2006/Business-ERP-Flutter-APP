import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      builder: (context, authSnapshot) {
        // ⬜ Plain white screen while auth resolves
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _blankWhiteScreen();
        }

        if (!authSnapshot.hasData) {
          return _blankWhiteScreen();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('admin')
              .doc(authSnapshot.data!.uid)
              .get(),
          builder: (context, adminSnapshot) {
            // ⬜ Plain white screen while checking admin
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              return _blankWhiteScreen();
            }

            if (!adminSnapshot.hasData || !adminSnapshot.data!.exists) {
              FirebaseAuth.instance.signOut();
              return _blankWhiteScreen();
            }

            // ✅ Authorized → show actual screen
            return child;
          },
        );
      },
    );
  }

  /// ⬜ Pure white screen, no widgets, no theme bleed
  Widget _blankWhiteScreen() {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(),
    );
  }
}