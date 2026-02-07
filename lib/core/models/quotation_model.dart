import 'package:cloud_firestore/cloud_firestore.dart';

class QuotationModel {

  String enquiryId;
  String companyId;
  String clientId;
  String salesManagerId;

  String productId;
  String productName;

  double baseFees;
  double discountPercent;
  double taxPercentage;
  double taxAmount;
  double finalAmount;

  QuotationModel({
    required this.enquiryId,
    required this.companyId,
    required this.clientId,
    required this.salesManagerId,
    required this.productId,
    required this.productName,
    required this.baseFees,
    required this.discountPercent,
    required this.taxPercentage,
    required this.taxAmount,
    required this.finalAmount,
  });

  // =========================
  // FIRESTORE MAP
  // =========================

  Map<String, dynamic> toMap() {

    return {

      "enquiryId": enquiryId,
      "companyId": companyId,
      "clientId": clientId,
      "salesManagerId": salesManagerId,

      "productSnapshot": {

        "productId": productId,
        "productName": productName,

        "baseFees": baseFees,
        "discountPercent": discountPercent,
        "taxPercentage": taxPercentage,

        "taxAmount": taxAmount,
        "finalAmount": finalAmount,
      },

      "quotationAmount": finalAmount,

      // Initial quotation state
      "status": "loi_sent",

      "pdfUrl": "",

      "createdAt": Timestamp.now(),
      "updatedAt": Timestamp.now(),
    };
  }
}
