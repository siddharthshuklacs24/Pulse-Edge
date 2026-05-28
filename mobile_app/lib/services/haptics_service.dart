import 'package:flutter/services.dart';

class HapticsService {
  static void elevated() {
    HapticFeedback.mediumImpact();
  }

  static void critical() {
    HapticFeedback.heavyImpact();
  }
}