import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../services/cloudinary_service.dart';

class PaymentInvoicePdfService {

  Future<String> generatePaymentReceipt({

    required String invoiceNumber,
    required String clientName,
    required double amount,
    required String paymentMode,

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
                "PAYMENT RECEIPT",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Invoice No: $invoiceNumber"),
              pw.Text("Client Name: $clientName"),
              pw.Text("Payment Mode: $paymentMode"),

              pw.SizedBox(height: 12),

              pw.Text("Paid Amount: ₹ $amount"),

              pw.SizedBox(height: 30),

              pw.Text("Payment Verified"),
              pw.Text("ERP System"),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();

    final file =
    File("${dir.path}/receipt_$invoiceNumber.pdf");

    await file.writeAsBytes(await pdf.save());

    // Upload receipt to cloud
    final url = await CloudinaryService().uploadFile(file);

    return url;
  }
}
