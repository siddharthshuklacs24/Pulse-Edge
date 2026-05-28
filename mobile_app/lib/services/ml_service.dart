import 'package:tflite_flutter/tflite_flutter.dart';

// ================================================================
// PulseEdge — TFLite Inference Service
// Loads heart_risk.tflite and runs predictions locally on device.
// Member 4 owns this file.
// ================================================================

class MLService {
  static Interpreter? _interpreter;

  /// Load the model from Flutter assets.
  /// Call this once at startup, or lazily on first prediction.
  static Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/models/heart_risk.tflite');
    print('✅ TFLite model loaded successfully');
  }

  /// Run inference with the user's 11 health inputs.
  /// Returns a float between 0.0 (no risk) and 1.0 (high risk).
  ///
  /// IMPORTANT: Inputs must be normalized BEFORE calling this.
  /// Use normalizeInputs() below first.
  static Future<double> predictRisk(List<double> normalizedInputs) async {
    if (_interpreter == null) {
      await loadModel();
    }

    // Input tensor shape: [1, 11] — one sample, 11 features
    final List<List<double>> inputTensor = [normalizedInputs];

    // Output tensor shape: [1, 1] — one sample, one probability
    final List<List<double>> outputTensor = [[0.0]];

    _interpreter!.run(inputTensor, outputTensor);

    final double riskScore = outputTensor[0][0];
    print('🫀 Risk Score: ${riskScore.toStringAsFixed(4)}');
    return riskScore;
  }

  /// Normalize raw user inputs to match the training data scale.
  ///
  /// Min/max values come from Member 1's train_and_convert.py output.
  /// Categorical/binary columns (Sex, ChestPainType, etc.) are NOT scaled.
  static List<double> normalizeInputs({
    required double age,
    required double sex,            // 0=Female, 1=Male
    required double chestPainType,  // ATA=0, NAP=1, ASY=2, TA=3
    required double restingBP,
    required double cholesterol,
    required double fastingBS,      // 0 or 1
    required double restingECG,     // Normal=0, ST=1, LVH=2
    required double maxHR,
    required double exerciseAngina, // 0=No, 1=Yes
    required double oldpeak,
    required double stSlope,        // Up=0, Flat=1, Down=2
  }) {
    // Helper to scale a value between its min and max
    double scale(double val, double min, double max) {
      if (max == min) return 0.0;
      final scaled = (val - min) / (max - min);
      return scaled.clamp(0.0, 1.0);
    }

    // IMPORTANT: Column ORDER must match training script exactly
    return [
      scale(age,         28.0,  77.0),  // index 0: Age
      sex,                               // index 1: Sex (binary)
      chestPainType,                   // index 2: ChestPainType (categorical)
      scale(restingBP,    0.0, 200.0),  // index 3: RestingBP
      scale(cholesterol,  0.0, 603.0),  // index 4: Cholesterol
      fastingBS,                         // index 5: FastingBS (binary)
      restingECG,                       // index 6: RestingECG (categorical)
      scale(maxHR,       60.0, 202.0),  // index 7: MaxHR
      exerciseAngina,                    // index 8: ExerciseAngina (binary)
      scale(oldpeak,     -2.6,   6.2),  // index 9: Oldpeak
      stSlope,                           // index 10: ST_Slope (categorical)
    ];
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}