import 'dart:math';
import '../core/constants.dart';

// ================================================================
// PulseEdge — Sensor Math Library
// Integrated: Member 3's detailed logic + Member 4's static class structure.
// These are PURE FUNCTIONS — no Flutter, no Riverpod, no async.
// ================================================================

class SensorMath {
  
  /// FUNCTION 1: Calculate Dynamic Signal Vector Magnitude
  ///
  /// Takes raw accelerometer values (in m/s²) from sensors_plus.
  /// Converts to g-force, computes vector magnitude, removes gravity.
  ///
  /// Why subtract 1.0?
  /// A phone sitting perfectly still still reads ~9.8 m/s² (1g) on one axis
  /// because gravity is always pulling on it.
  /// Subtracting 1.0 removes this constant gravity so we only measure MOVEMENT.
  static double calculateSVM(double ax, double ay, double az) {
    // Step 1: Convert m/s² to g-force by dividing by 9.8
    final double axG = ax / 9.8;
    final double ayG = ay / 9.8;
    final double azG = az / 9.8;

    // Step 2: Calculate total vector magnitude (Pythagorean theorem in 3D)
    final double totalMagnitude = sqrt(axG * axG + ayG * ayG + azG * azG);

    // Step 3: Subtract 1g to remove constant gravity component
    final double dynamicSVM = totalMagnitude - 1.0;

    // Step 4: Clamp at 0 — negative values are just noise when still
    return dynamicSVM < 0.0 ? 0.0 : dynamicSVM;
  }

  /// FUNCTION 2: Normalize SVM to 0.0–1.0
  ///
  /// Raw SVM values can go above 1.0 during vigorous activity.
  /// We scale it against MAX_EXPECTED_SVM defined in constants.dart.
  ///
  /// Example:
  ///   rawSVM = 0.0  → 0.0  (sitting still)
  ///   rawSVM = 2.5  → 1.0  (clamped at max)
  static double normalizeSVM(double rawSVM) {
    final double normalized = rawSVM / MAX_EXPECTED_SVM;
    
    // Using clean .clamp() syntax for 0.0 to 1.0
    return normalized.clamp(0.0, 1.0);
  }

  /// FUNCTION 3: Compute Average of a List of Samples
  ///
  /// Collects raw sensor readings over a window, then averages them.
  /// This smooths out sudden spikes (e.g., phone being picked up).
  static double computeAverage(List<double> samples) {
    if (samples.isEmpty) return 0.0;
    return samples.reduce((a, b) => a + b) / samples.length;
  }

  /// FUNCTION 4: Classify Activity from Intensity Value
  ///
  /// Maps the 0.0–1.0 intensity to a human-readable activity label.
  /// Thresholds come from constants.dart.
  ///
  /// Ranges:
  ///   0.00–0.20 → SITTING
  ///   0.21–0.60 → WALKING
  ///   0.61–1.00 → RUNNING
  static String classifyActivity(double intensity) {
    if (intensity <= INTENSITY_SITTING_MAX) return ACTIVITY_SITTING;
    if (intensity <= INTENSITY_WALKING_MAX) return ACTIVITY_WALKING;
    return ACTIVITY_RUNNING;
  }
}