import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.navy,
              )),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
