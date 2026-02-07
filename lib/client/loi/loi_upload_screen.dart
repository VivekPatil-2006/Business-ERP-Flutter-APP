// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../core/services/cloudinary_service.dart';
// import '../../core/services/notification_service.dart';
//
// class LoiUploadScreen extends StatefulWidget {
//
//   final String quotationId;
//   final String salesManagerId;
//
//   const LoiUploadScreen({
//     super.key,
//     required this.quotationId,
//     required this.salesManagerId,
//   });
//
//   @override
//   State<LoiUploadScreen> createState() => _LoiUploadScreenState();
// }
//
// class _LoiUploadScreenState extends State<LoiUploadScreen> {
//
//   File? file;
//   bool loading = false;
//
//   pickFile() async {
//
//     final picked =
//     await ImagePicker().pickImage(source: ImageSource.gallery);
//
//     if (picked != null) {
//       setState(() {
//         file = File(picked.path);
//       });
//     }
//   }
//
//   uploadLoi() async {
//
//     if (file == null) return;
//
//     setState(() => loading = true);
//
//     final clientId = FirebaseAuth.instance.currentUser!.uid;
//
//     final url =
//     await CloudinaryService().uploadFile(file!);
//
//     // ================= SAVE LOI =================
//
//     await FirebaseFirestore.instance.collection("loi").add({
//
//       "quotationId": widget.quotationId,
//       "clientId": clientId,
//       "salesManagerId": widget.salesManagerId,
//
//       "status": "pending",
//       "attachmentUrl": url,
//
//       "createdAt": Timestamp.now(),
//     });
//
//     // ================= UPDATE QUOTATION =================
//
//     await FirebaseFirestore.instance
//         .collection("quotations")
//         .doc(widget.quotationId)
//         .update({
//
//       "status": "loi_sent",
//       "updatedAt": Timestamp.now(),
//     });
//
//     // ================= NOTIFY SALES =================
//
//     await NotificationService().sendNotification(
//
//       userId: widget.salesManagerId,
//       role: "sales_manager",
//
//       title: "LOI Received",
//       message: "Client uploaded LOI document",
//
//       type: "loi",
//       referenceId: widget.quotationId,
//     );
//
//     setState(() => loading = false);
//
//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text("LOI Uploaded")));
//
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       appBar: AppBar(title: const Text("Upload LOI")),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//
//         child: Column(
//           children: [
//
//             ElevatedButton.icon(
//               icon: const Icon(Icons.upload),
//               label: const Text("Select LOI File"),
//               onPressed: pickFile,
//             ),
//
//             const SizedBox(height: 10),
//
//             file == null
//                 ? const Text("No file selected")
//                 : const Text("File selected ✔"),
//
//             const SizedBox(height: 25),
//
//             SizedBox(
//               width: double.infinity,
//
//               child: ElevatedButton(
//                 onPressed: loading ? null : uploadLoi,
//                 child: loading
//                     ? const CircularProgressIndicator()
//                     : const Text("SUBMIT LOI"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
