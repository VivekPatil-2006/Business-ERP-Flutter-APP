import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class PdfUtils {

  // -----------------------
  // OPEN PDF
  // -----------------------

  static Future<void> openPdf(String filePath) async {
    await OpenFilex.open(filePath);
  }

  // -----------------------
  // DOWNLOAD PDF
  // -----------------------

  static Future<String> downloadPdf({

    required String url,
    required String fileName,

  }) async {

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Failed to download file");
    }

    final directory = await getApplicationDocumentsDirectory();

    final filePath = "${directory.path}/$fileName.pdf";

    final file = File(filePath);

    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }
}
