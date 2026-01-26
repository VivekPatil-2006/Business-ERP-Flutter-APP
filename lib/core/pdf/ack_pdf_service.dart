import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class AckPdfService {

  Future<String> generateAckPdf({
    required String quotationId,
    required String clientName,
    required String decision,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.Page(
        build: (context) {

          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),

            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                pw.Text(
                  "ACKNOWLEDGEMENT LETTER",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text("Date: ${DateFormat.yMMMd().format(DateTime.now())}"),

                pw.SizedBox(height: 20),

                pw.Text("Quotation Reference: $quotationId"),

                pw.SizedBox(height: 20),

                pw.Text("Dear $clientName,"),

                pw.SizedBox(height: 12),

                pw.Text(
                  decision == "ACCEPTED"
                      ? "We are pleased to inform you that your Letter of Intent (LOI) has been ACCEPTED. You may proceed with the payment process."
                      : "We regret to inform you that your Letter of Intent (LOI) has been REJECTED. Please contact our sales department for clarification.",
                ),

                pw.SizedBox(height: 30),

                pw.Text("Regards,"),

                pw.SizedBox(height: 10),

                pw.Text("Sales Manager"),

                pw.Text("ERP System"),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();

    final file = File(
      "${dir.path}/ACK_$quotationId.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
