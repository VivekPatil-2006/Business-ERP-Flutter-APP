import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/theme/app_colors.dart';

class ClientLoiUploadScreen extends StatefulWidget {

  final String quotationId;

  const ClientLoiUploadScreen({
    super.key,
    required this.quotationId,
  });

  @override
  State<ClientLoiUploadScreen> createState() =>
      _ClientLoiUploadScreenState();
}

class _ClientLoiUploadScreenState extends State<ClientLoiUploadScreen> {

  File? file;
  bool uploading = false;

  // ================= PICK OPTIONS =================

  void showPickOptions() {

    showModalBottomSheet(
      context: context,
      builder: (_) {

        return SafeArea(
          child: Wrap(
            children: [

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose Image"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),

              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text("Choose PDF"),
                onTap: () {
                  Navigator.pop(context);
                  pickPdf();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= IMAGE PICK =================

  Future<void> pickImage(ImageSource source) async {

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        file = File(picked.path);
      });
    }
  }

  // ================= PDF PICK =================

  Future<void> pickPdf() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
    }
  }

  // ================= UPLOAD LOI =================

  Future<void> uploadLoi() async {

    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select LOI file")),
      );
      return;
    }

    try {

      setState(() => uploading = true);

      // ================= FETCH QUOTATION =================

      final quoteSnap = await FirebaseFirestore.instance
          .collection("quotations")
          .doc(widget.quotationId)
          .get();

      if (!quoteSnap.exists) {
        throw Exception("Quotation not found");
      }

      final quoteData = quoteSnap.data()!;

      final clientId = quoteData['clientId'];
      final salesManagerId = quoteData['salesManagerId'];
      final enquiryId = quoteData['enquiryId'];
      final companyId = quoteData['companyId'];

      // ================= UPLOAD FILE =================

      final fileUrl =
      await CloudinaryService().uploadFile(file!);

      // ================= SAVE LOI =================

      await FirebaseFirestore.instance
          .collection("loi")
          .add({

        "quotationId": widget.quotationId,
        "enquiryId": enquiryId,

        "companyId": companyId,
        "clientId": clientId,
        "salesManagerId": salesManagerId,

        "attachmentUrl": fileUrl,

        // schema field name
        "filetype": file!.path.endsWith(".pdf") ? "pdf" : "image",

        "status": "pending",

        "createdAt": Timestamp.now(),
      });

      // ================= UPDATE QUOTATION =================

      await FirebaseFirestore.instance
          .collection("quotations")
          .doc(widget.quotationId)
          .update({

        "status": "loi_sent",
        "updatedAt": Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("LOI Uploaded Successfully")),
      );

      Navigator.pop(context);

    } catch (e) {

      debugPrint("LOI Upload Error => $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload Failed")),
      );

    } finally {

      if (mounted) {
        setState(() => uploading = false);
      }
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload LOI"),
        backgroundColor: AppColors.darkBlue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),

              child: Column(
                children: [

                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 60,
                    color: AppColors.primaryBlue,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Upload LOI (Image or PDF)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: uploading ? null : showPickOptions,
                    icon: const Icon(Icons.attach_file),
                    label: const Text("Choose File"),
                  ),

                  const SizedBox(height: 12),

                  if (file != null)
                    Row(
                      children: [

                        Icon(
                          file!.path.endsWith(".pdf")
                              ? Icons.picture_as_pdf
                              : Icons.image,
                          color: Colors.blue,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            file!.path.split("/").last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const Icon(Icons.check_circle,
                            color: Colors.green),
                      ],
                    ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                onPressed: uploading ? null : uploadLoi,

                child: uploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "UPLOAD LOI",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
