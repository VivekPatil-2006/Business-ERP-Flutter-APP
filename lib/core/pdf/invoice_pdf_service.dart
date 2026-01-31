import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class InvoicePdfService {

  Future<File> generateInvoicePdf({

    required String invoiceNumber,
    required String clientName,
    required String description,
    required double amount,

  }) async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.Page(
        margin: const pw.EdgeInsets.all(24),

        build: (context) {

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text(
                "INVOICE",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Invoice Number: $invoiceNumber"),
              pw.Text("Client Name: $clientName"),
              pw.Text("Description: $description"),

              pw.SizedBox(height: 12),

              pw.Text("Total Amount: ₹ $amount"),

              pw.SizedBox(height: 30),

              pw.Text("Authorized Signature"),
              pw.Text("ERP System"),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();

    final file = File("${dir.path}/invoice_$invoiceNumber.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
