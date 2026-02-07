import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {

  String quotationId;
  String companyId;
  String clientId;
  String salesManagerId;

  double amount;

  String phase;
  String paymentType;
  String paymentMode;

  String paymentProofUrl;

  PaymentModel({
    required this.quotationId,
    required this.companyId,
    required this.clientId,
    required this.salesManagerId,
    required this.amount,
    required this.phase,
    required this.paymentType,
    required this.paymentMode,
    required this.paymentProofUrl,
  });

  // ======================
  // FIRESTORE MAP
  // ======================

  Map<String, dynamic> toMap() {

    return {

      "quotationId": quotationId,
      "companyId": companyId,
      "clientId": clientId,
      "salesManagerId": salesManagerId,

      "amount": amount,

      "phase": phase,
      "paymentType": paymentType,
      "paymentMode": paymentMode,

      "paymentProofUrl": paymentProofUrl,

      "status": "pending",

      "createdAt": Timestamp.now(),
    };
  }
}
