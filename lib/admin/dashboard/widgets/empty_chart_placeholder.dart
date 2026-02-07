import 'package:flutter/material.dart';

class EmptyChartPlaceholder extends StatelessWidget {
  final String message;

  const EmptyChartPlaceholder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
