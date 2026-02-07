// import 'package:flutter/material.dart';
//
// class LoiFileViewer extends StatelessWidget {
//
//   final String url;
//   final String fileType;
//
//   const LoiFileViewer({
//     super.key,
//     required this.url,
//     required this.fileType,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("View LOI")),
//
//       body: Center(
//
//         child: fileType == "pdf"
//
//             ? const Text("PDF opened externally")
//
//             : InteractiveViewer(
//           child: Image.network(
//             url,
//             fit: BoxFit.contain,
//             loadingBuilder: (_, child, progress) {
//               if (progress == null) return child;
//               return const CircularProgressIndicator();
//             },
//             errorBuilder: (_, __, ___) =>
//             const Text("Failed to load file"),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';

class LoiFileViewer extends StatelessWidget {
  final String url;
  final String fileType; // "pdf" | "image"

  const LoiFileViewer({
    super.key,
    required this.url,
    required this.fileType,
  });

  // =============================
  // OPEN PDF EXTERNALLY
  // =============================

  Future<void> _openPdf(BuildContext context) async {
    final uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open PDF")),
      );
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View LOI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: "Open externally",
            onPressed: () => _openPdf(context),
          ),
        ],
      ),

      body: fileType.toLowerCase() == "pdf"
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              "PDF Document",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text("Open PDF"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
              ),
              onPressed: () => _openPdf(context),
            ),
          ],
        ),
      )

      // ================= IMAGE PREVIEW =================
          : InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 4,
        child: Center(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator();
            },
            errorBuilder: (_, __, ___) => const Text(
              "Failed to load file",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
