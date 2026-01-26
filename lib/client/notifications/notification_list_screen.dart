import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/notification_service.dart';
import 'notification_tile.dart';


class NotificationListScreen extends StatelessWidget {

  final String userId;

  const NotificationListScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("notifications")
            .where("userId", isEqualTo: userId)
            .snapshots(), // ❗ removed orderBy to avoid index crash

        builder: (context, snapshot) {

          // ---------------- LOADING ----------------

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ---------------- NO DATA ----------------

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Notifications"));
          }

          // ---------------- SORT LOCALLY ----------------

          final notifications = snapshot.data!.docs.toList()
            ..sort((a, b) {

              final aTime =
              a.data().toString().contains("createdAt")
                  ? a['createdAt']
                  : Timestamp.now();

              final bTime =
              b.data().toString().contains("createdAt")
                  ? b['createdAt']
                  : Timestamp.now();

              return bTime.compareTo(aTime);
            });

          // ---------------- UI ----------------

          return ListView.builder(
            itemCount: notifications.length,

            itemBuilder: (context, index) {

              final n = notifications[index];

              return NotificationTile(

                title: n['title'] ?? "Notification",

                message: n['message'] ?? "",

                isRead: n['isRead'] ?? false,

                onTap: () async {

                  await NotificationService()
                      .markAsRead(n.id);

                },
              );
            },
          );
        },
      ),
    );
  }
}
