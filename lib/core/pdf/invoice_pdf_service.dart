import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class InvoicePdfService {

  Future<File> generateInvoicePdf({
    required String quotationId,
    required String productName,
    required double amount,
    required double gst,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            pw.Text("INVOICE",
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold)),

            pw.SizedBox(height: 20),

            pw.Text("Quotation ID: $quotationId"),
            pw.Text("Product: $productName"),
            pw.Text("GST: $gst%"),
            pw.Text("Total Amount: ₹ $amount"),

            pw.SizedBox(height: 30),

            pw.Text("Thank you for your business."),
          ],
        ),
      ),
    );

    final dir = await getTemporaryDirectory();

    final file =
    File("${dir.path}/invoice_$quotationId.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
