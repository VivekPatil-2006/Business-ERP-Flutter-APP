// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class NotificationService {
//
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   // -------------------------
//   // CREATE NOTIFICATION
//   // -------------------------
//
//   Future<void> sendNotification({
//
//     required String userId,
//     required String role,
//     required String title,
//     required String message,
//     required String type,
//     required String referenceId,
//
//   }) async {
//
//     await _db.collection("notifications").add({
//
//       "userId": userId,
//       "role": role,
//
//       "title": title,
//       "message": message,
//
//       "type": type,
//       "referenceId": referenceId,
//
//       "isRead": false,
//
//       "createdAt": Timestamp.now(),
//     });
//   }
//
//   // -------------------------
//   // MARK AS READ
//   // -------------------------
//
//   Future<void> markAsRead(String notificationId) async {
//
//     await _db
//         .collection("notifications")
//         .doc(notificationId)
//         .update({
//
//       "isRead": true,
//
//     });
//   }
// }
