import 'package:flutter/material.dart';

class RiskProgress extends StatelessWidget {
  final double value;

  const RiskProgress({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Risk ${(value * 100).toStringAsFixed(1)}%"),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: Colors.white12,
            valueColor:
                const AlwaysStoppedAnimation(Color(0xFF00E5FF)),
          ),
        ),
      ],
    );
  }
}