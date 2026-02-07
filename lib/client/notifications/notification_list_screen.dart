// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../core/services/notification_service.dart';
// import '../../core/theme/app_colors.dart';
// import 'notification_tile.dart';
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
//       appBar: AppBar(
//         backgroundColor: AppColors.darkBlue, // navy blue
//         elevation: 0,
//
//         iconTheme: const IconThemeData(
//           color: Colors.white, // back arrow
//         ),
//
//         title: const Text(
//           "Notifications",
//           style: TextStyle(
//             color: Colors.white, // text in white
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//
//
//       body: StreamBuilder<QuerySnapshot>(
//
//         stream: FirebaseFirestore.instance
//             .collection("notifications")
//             .where("userId", isEqualTo: userId)
//             .orderBy("createdAt", descending: true) // ✅ realtime ordered
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
//             padding: const EdgeInsets.only(bottom: 10),
//             itemCount: notifications.length,
//
//             itemBuilder: (context, index) {
//
//               final n = notifications[index];
//               final data = n.data() as Map<String, dynamic>;
//
//               return NotificationTile(
//
//                 title: data['title'] ?? "Notification",
//
//                 message: data['message'] ?? "",
//
//                 isRead: data['isRead'] ?? false,
//
//                 onTap: () async {
//
//                   if (!(data['isRead'] ?? false)) {
//                     await NotificationService()
//                         .markAsRead(n.id);
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
