import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {

  String invoiceId;
  String clientId;
  double amount;
  String phase;
  String paymentMode;
  String paymentType;
  String paymentProofUrl;

  PaymentModel({
    required this.invoiceId,
    required this.clientId,
    required this.amount,
    required this.phase,
    required this.paymentMode,
    required this.paymentType,
    required this.paymentProofUrl,
  });

  Map<String, dynamic> toMap() {

    return {
      "invoiceId": invoiceId,
      "clientId": clientId,
      "amount": amount,
      "phase": phase,
      "paymentMode": paymentMode,
      "paymentType": paymentType,
      "paymentProofUrl": paymentProofUrl,

      "status": "pending",

      "createdAt": Timestamp.now(), // ✅ FIXED
    };
  }
}
