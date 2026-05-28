import 'package:flutter/material.dart';
import '../services/haptics_service.dart';

class AlertBanner extends StatelessWidget {
  final String level;

  const AlertBanner({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (level) {
      case "CRITICAL":
        color = Colors.red;
        HapticsService.critical();
        break;
      case "ELEVATED":
        color = Colors.yellow;
        HapticsService.elevated();
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(level, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (level == "CRITICAL")
            const Text("SIT DOWN IMMEDIATELY"),
        ],
      ),
    );
  }
}