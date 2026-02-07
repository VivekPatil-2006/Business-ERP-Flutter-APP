import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String message;
  final Color color;

  const AlertCard({
    super.key,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
