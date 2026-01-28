import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/theme/app_colors.dart';


class SalesProfileScreen extends StatefulWidget {
  const SalesProfileScreen({super.key});

  @override
  State<SalesProfileScreen> createState() => _SalesProfileScreenState();
}

class _SalesProfileScreenState extends State<SalesProfileScreen> {

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  File? imageFile;
  String profileUrl = "";

  bool loading = false;

  String get uid => auth.currentUser!.uid;

  // -------------------------
  // Load Profile
  // -------------------------

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {

    final doc = await firestore
        .collection("sales_managers")
        .doc(uid)
        .get();

    if (doc.exists) {

      final data = doc.data()!;

      nameCtrl.text = data['name'] ?? "";
      phoneCtrl.text = data['phone'] ?? "";
      addressCtrl.text = data['addressLine1'] ?? "";
      emailCtrl.text = auth.currentUser!.email ?? "";

      profileUrl = data['profileImage'] ?? "";

      setState(() {});
    }
  }

  // -------------------------
  // Pick Profile Image
  // -------------------------

  pickImage() async {

    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  // -------------------------
  // Update Profile
  // -------------------------

  Future<void> updateProfile() async {

    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
      showMsg("Name and Phone required");
      return;
    }

    try {

      setState(() => loading = true);

      String imageUrl = profileUrl;

      // Upload new image if selected
      if (imageFile != null) {
        imageUrl =
        await CloudinaryService().uploadFile(imageFile!);
      }

      // Update Firestore
      await firestore
          .collection("sales_managers")
          .doc(uid)
          .update({

        "name": nameCtrl.text,
        "phone": phoneCtrl.text,
        "addressLine1": addressCtrl.text,
        "profileImage": imageUrl,

      });

      // Update Email
      if (emailCtrl.text != auth.currentUser!.email) {
        await auth.currentUser!
            .updateEmail(emailCtrl.text.trim());
      }

      // Update Password (if entered)
      if (passwordCtrl.text.isNotEmpty) {
        await auth.currentUser!
            .updatePassword(passwordCtrl.text.trim());
      }

      showMsg("Profile Updated Successfully");

    } catch (e) {

      showMsg("Error: ${e.toString()}");

    } finally {
      setState(() => loading = false);
    }
  }

  // -------------------------
  // UI
  // -------------------------

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // Profile Image
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.lightGrey,
                backgroundImage:
                imageFile != null
                    ? FileImage(imageFile!)
                    : (profileUrl.isNotEmpty
                    ? NetworkImage(profileUrl)
                    : null) as ImageProvider?,

                child: profileUrl.isEmpty && imageFile == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            buildField("Name", nameCtrl),
            buildField("Phone", phoneCtrl,
                keyboard: TextInputType.phone),

            buildField("Email", emailCtrl,
                keyboard: TextInputType.emailAddress),

            buildField("Address", addressCtrl),


            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                onPressed: loading ? null : updateProfile,

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("UPDATE PROFILE"),
              ),
            )

          ],
        ),
      ),
    );
  }

  // -------------------------
  // Input Widget
  // -------------------------

  Widget buildField(
      String label,
      TextEditingController controller, {
        bool isPassword = false,
        TextInputType keyboard = TextInputType.text,
      }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: isPassword,

        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // -------------------------
  // Snackbar
  // -------------------------

  void showMsg(String msg) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // -------------------------
  // Dispose
  // -------------------------

  @override
  void dispose() {

    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }
}
