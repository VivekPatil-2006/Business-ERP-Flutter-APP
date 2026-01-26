class QuotationModel {

  String enquiryId;
  String clientId;
  String salesManagerId;

  String productId;
  String productName;

  double baseFees;
  double discountPercent;
  double taxPercent;
  double taxAmount;
  double finalAmount;

  QuotationModel({
    required this.enquiryId,
    required this.clientId,
    required this.salesManagerId,
    required this.productId,
    required this.productName,
    required this.baseFees,
    required this.discountPercent,
    required this.taxPercent,
    required this.taxAmount,
    required this.finalAmount,
  });

  // =========================
  // FIRESTORE MAP
  // =========================

  Map<String, dynamic> toMap() {

    return {

      "enquiryId": enquiryId,
      "clientId": clientId,
      "salesManagerId": salesManagerId,

      "productSnapshot": {

        "productId": productId,
        "productName": productName,

        "baseFees": baseFees,
        "discountPercent": discountPercent,
        "taxPercentage": taxPercent,

        "taxAmount": taxAmount,
        "finalAmount": finalAmount,
      },

      "quotationAmount": finalAmount,

      "status": "sent",
      "pdfUrl": "",

      "createdAt": DateTime.now(),
      "updatedAt": DateTime.now(),
    };
  }
}
