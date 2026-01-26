import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../services/cloudinary_service.dart';

class PaymentInvoicePdfService {

  Future<String> generatePaymentInvoice({

    required String invoiceNumber,
    required String clientName,
    required double amount,
    required String paymentMode,

  }) async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.Page(

        build: (context) {

          return pw.Column(

            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [

              pw.Text(
                "PAYMENT INVOICE",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text("Invoice No: $invoiceNumber"),
              pw.Text("Client: $clientName"),
              pw.Text("Payment Mode: $paymentMode"),
              pw.Text("Total Paid: ₹ $amount"),

              pw.SizedBox(height: 30),

              pw.Text("Thank you for your business."),
              pw.Text("Demo Company Pvt Ltd"),

            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/payment_$invoiceNumber.pdf");

    await file.writeAsBytes(await pdf.save());

    // Upload to Cloudinary
    final url = await CloudinaryService().uploadFile(file);

    return url;
  }
}
