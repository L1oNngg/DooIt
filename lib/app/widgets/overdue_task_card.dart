import 'package:flutter/material.dart';

class OverdueTaskCard extends StatelessWidget {
  final Widget child;
  const OverdueTaskCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: child,
    );
  }
}
