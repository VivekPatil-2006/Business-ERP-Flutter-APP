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

  File? imageFile;
  String profileUrl = "";

  bool loading = false;

  String get uid => auth.currentUser!.uid;

  // ================= LOAD PROFILE =================

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

    if (!doc.exists) return;

    final data = doc.data()!;

    nameCtrl.text = data['name'] ?? "";
    phoneCtrl.text = data['phone'] ?? "";
    addressCtrl.text = data['addressLine1'] ?? "";
    emailCtrl.text = auth.currentUser!.email ?? "";

    profileUrl = data['profileImage'] ?? "";

    if (mounted) {
      setState(() {});
    }
  }

  // ================= PICK IMAGE =================

  pickImage() async {

    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  // ================= UPDATE PROFILE =================

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
        imageUrl = await CloudinaryService().uploadFile(imageFile!);
      }

      // Update Firestore
      await firestore
          .collection("sales_managers")
          .doc(uid)
          .update({

        "name": nameCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "addressLine1": addressCtrl.text.trim(),
        "profileImage": imageUrl,
      });

      // Update Email (Firebase Auth)
      if (emailCtrl.text.trim() != auth.currentUser!.email) {

        try {
          await auth.currentUser!
              .updateEmail(emailCtrl.text.trim());
        } catch (e) {

          showMsg("Re-login required to update email");
        }
      }

      showMsg("Profile Updated Successfully");

    } catch (e) {

      showMsg("Update failed");

    } finally {

      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    ImageProvider? avatarImage;

    if (imageFile != null) {
      avatarImage = FileImage(imageFile!);
    }
    else if (profileUrl.isNotEmpty) {
      avatarImage = NetworkImage(profileUrl);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // ================= PROFILE IMAGE =================

            GestureDetector(
              onTap: pickImage,

              child: CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.lightGrey,
                backgroundImage: avatarImage,

                child: avatarImage == null
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
                    : const Text("UPDATE PROFILE",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= INPUT =================

  Widget buildField(
      String label,
      TextEditingController controller, {
        TextInputType keyboard = TextInputType.text,
      }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,
        keyboardType: keyboard,

        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // ================= SNACKBAR =================

  void showMsg(String msg) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ================= DISPOSE =================

  @override
  void dispose() {

    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();

    super.dispose();
  }
}
