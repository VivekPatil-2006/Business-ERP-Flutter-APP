import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';

class AckUploadScreen extends StatefulWidget {

  final String quotationId;
  final String clientId;

  const AckUploadScreen({
    super.key,
    required this.quotationId,
    required this.clientId,
  });

  @override
  State<AckUploadScreen> createState() => _AckUploadScreenState();
}

class _AckUploadScreenState extends State<AckUploadScreen> {

  File? ackFile;
  bool loading = false;

  // ======================
  // PICK FILE
  // ======================

  Future<void> pickFile() async {

    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        ackFile = File(picked.path);
      });
    }
  }

  // ======================
  // SUBMIT ACK
  // ======================

  Future<void> submitAck() async {

    if (ackFile == null) return;

    try {

      setState(() => loading = true);

      // Upload to Cloudinary
      final ackUrl =
      await CloudinaryService().uploadFile(ackFile!);

      // Save ACK record
      await FirebaseFirestore.instance
          .collection("acknowledgements")
          .add({

        "quotationId": widget.quotationId,
        "clientId": widget.clientId,

        "pdfUrl": ackUrl,
        "status": "sent",

        "createdAt": Timestamp.now(),
      });

      // Update quotation
      await FirebaseFirestore.instance
          .collection("quotations")
          .doc(widget.quotationId)
          .update({

        "ackPdfUrl": ackUrl,
        "updatedAt": Timestamp.now(),
      });

      // Notify client
      await NotificationService().sendNotification(

        userId: widget.clientId,
        role: "client",

        title: "Acknowledgement Letter",
        message: "Acknowledgement letter has been sent",

        type: "ack",
        referenceId: widget.quotationId,
      );

      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {

      debugPrint("ACK Upload Error => $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload ACK")),
      );

    } finally {

      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Upload Acknowledgement"),
        backgroundColor: AppColors.primaryBlue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text("Upload ACK Letter"),
              onPressed: pickFile,
            ),

            const SizedBox(height: 15),

            ackFile == null
                ? const Text("No file selected")
                : const Text("File Selected ✔"),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),

                onPressed: loading ? null : submitAck,

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SEND ACK"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
