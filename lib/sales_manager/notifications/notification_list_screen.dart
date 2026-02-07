// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'notification_tile.dart';
// import '../../core/services/notification_service.dart';
//
// class NotificationListScreen extends StatelessWidget {
//
//   final String userId;
//
//   const NotificationListScreen({
//     super.key,
//     required this.userId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       appBar: AppBar(
//         title: const Text("Notifications"),
//       ),
//
//       body: StreamBuilder<QuerySnapshot>(
//
//         // ✅ TRUE REALTIME STREAM WITH SERVER SORTING
//         stream: FirebaseFirestore.instance
//             .collection("notifications")
//             .where("userId", isEqualTo: userId)
//             .orderBy("createdAt", descending: true)
//             .snapshots(),
//
//         builder: (context, snapshot) {
//
//           // ---------------- LOADING ----------------
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           // ---------------- ERROR ----------------
//
//           if (snapshot.hasError) {
//             return const Center(
//               child: Text("Failed to load notifications"),
//             );
//           }
//
//           // ---------------- EMPTY ----------------
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No Notifications"));
//           }
//
//           final notifications = snapshot.data!.docs;
//
//           // ---------------- UI ----------------
//
//           return ListView.builder(
//
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.symmetric(vertical: 8),
//
//             itemCount: notifications.length,
//
//             itemBuilder: (context, index) {
//
//               final doc = notifications[index];
//               final data = doc.data() as Map<String, dynamic>;
//
//               final String title = data['title'] ?? "Notification";
//               final String message = data['message'] ?? "";
//               final bool isRead = data['isRead'] ?? false;
//
//               return NotificationTile(
//
//                 title: title,
//
//                 message: message,
//
//                 isRead: isRead,
//
//                 onTap: () async {
//
//                   try {
//
//                     // ✅ REALTIME UPDATE (UI AUTO REFRESHES)
//                     await NotificationService()
//                         .markAsRead(doc.id);
//
//                   } catch (e) {
//
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Failed to mark as read"),
//                       ),
//                     );
//                   }
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
