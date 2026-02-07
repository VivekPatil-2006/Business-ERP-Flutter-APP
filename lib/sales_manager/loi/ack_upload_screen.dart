// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../core/services/cloudinary_service.dart';
// import '../../core/services/notification_service.dart';
// import '../../core/theme/app_colors.dart';
//
// class AckUploadScreen extends StatefulWidget {
//
//   final String quotationId;
//   final String clientId;
//
//   const AckUploadScreen({
//     super.key,
//     required this.quotationId,
//     required this.clientId,
//   });
//
//   @override
//   State<AckUploadScreen> createState() => _AckUploadScreenState();
// }
//
// class _AckUploadScreenState extends State<AckUploadScreen> {
//
//   File? ackFile;
//   bool loading = false;
//
//   // ======================
//   // PICK FILE
//   // ======================
//
//   Future<void> pickFile() async {
//
//     final picked =
//     await ImagePicker().pickImage(source: ImageSource.gallery);
//
//     if (picked != null) {
//       setState(() {
//         ackFile = File(picked.path);
//       });
//     }
//   }
//
//   // ======================
//   // SUBMIT ACK
//   // ======================
//
//   Future<void> submitAck() async {
//
//     if (ackFile == null) return;
//
//     try {
//
//       setState(() => loading = true);
//
//       // Upload to Cloudinary
//       final ackUrl =
//       await CloudinaryService().uploadFile(ackFile!);
//
//       // Save ACK record
//       await FirebaseFirestore.instance
//           .collection("acknowledgements")
//           .add({
//
//         "quotationId": widget.quotationId,
//         "clientId": widget.clientId,
//
//         "pdfUrl": ackUrl,
//         "status": "sent",
//
//         "createdAt": Timestamp.now(),
//       });
//
//       // Update quotation
//       await FirebaseFirestore.instance
//           .collection("quotations")
//           .doc(widget.quotationId)
//           .update({
//
//         "ackPdfUrl": ackUrl,
//         "updatedAt": Timestamp.now(),
//       });
//
//       // Notify client
//       await NotificationService().sendNotification(
//
//         userId: widget.clientId,
//         role: "client",
//
//         title: "Acknowledgement Letter",
//         message: "Acknowledgement letter has been sent",
//
//         type: "ack",
//         referenceId: widget.quotationId,
//       );
//
//       if (!mounted) return;
//       Navigator.pop(context);
//
//     } catch (e) {
//
//       debugPrint("ACK Upload Error => $e");
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to upload ACK")),
//       );
//
//     } finally {
//
//       if (mounted) {
//         setState(() => loading = false);
//       }
//     }
//   }
//
//   // ======================
//   // UI
//   // ======================
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text("Upload Acknowledgement"),
//         backgroundColor: AppColors.primaryBlue,
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//
//         child: Column(
//           children: [
//
//             ElevatedButton.icon(
//               icon: const Icon(Icons.upload),
//               label: const Text("Upload ACK Letter"),
//               onPressed: pickFile,
//             ),
//
//             const SizedBox(height: 15),
//
//             ackFile == null
//                 ? const Text("No file selected")
//                 : const Text("File Selected ✔"),
//
//             const SizedBox(height: 25),
//
//             SizedBox(
//               width: double.infinity,
//
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryBlue,
//                 ),
//
//                 onPressed: loading ? null : submitAck,
//
//                 child: loading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text("SEND ACK"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/cloudinary_service.dart';
import '../loi/services/loi_service.dart';

class AckUploadScreen extends StatefulWidget {
  final String quotationId;

  const AckUploadScreen({
    super.key,
    required this.quotationId,
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
    if (ackFile == null) {
      showMsg("Please select ACK file");
      return;
    }

    try {
      setState(() => loading = true);

      // 1️⃣ Upload to Cloudinary
      final ackUrl =
      await CloudinaryService().uploadFile(ackFile!);

      // 2️⃣ Send ACK via LOI API
      await LoiService().sendAck(
        quotationId: widget.quotationId,
        ackPdfUrl: ackUrl,
      );

      showMsg("Acknowledgement sent successfully");

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("ACK Upload Error => $e");
      showMsg("Failed to upload acknowledgement");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload Acknowledgement",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text("Select ACK File"),
              onPressed: loading ? null : pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(height: 15),

            ackFile == null
                ? const Text("No file selected")
                : Text(
              "Selected: ${ackFile!.path.split('/').last}",
              style: const TextStyle(
                  fontWeight: FontWeight.w600),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: loading ? null : submitAck,
                child: loading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "SEND ACK",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
