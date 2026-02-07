import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class NotificationTile extends StatelessWidget {

  final String title;
  final String message;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.title,
    required this.message,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      color: isRead
          ? Colors.white
          : AppColors.neonBlue.withOpacity(0.15),

      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      child: ListTile(

        leading: Icon(
          isRead
              ? Icons.notifications_none
              : Icons.notifications_active,
          color: AppColors.primaryBlue,
        ),

        title: Text(
          title,
          style: TextStyle(
            fontWeight:
            isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),

        subtitle: Text(message),

        onTap: onTap,
      ),
    );
  }
}
