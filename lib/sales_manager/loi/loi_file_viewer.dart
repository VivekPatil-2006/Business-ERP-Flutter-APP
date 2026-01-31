import 'package:flutter/material.dart';

class LoiFileViewer extends StatelessWidget {

  final String url;
  final String fileType;

  const LoiFileViewer({
    super.key,
    required this.url,
    required this.fileType,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("View LOI")),

      body: Center(

        child: fileType == "pdf"

            ? const Text("PDF opened externally")

            : InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator();
            },
            errorBuilder: (_, __, ___) =>
            const Text("Failed to load file"),
          ),
        ),
      ),
    );
  }
}
