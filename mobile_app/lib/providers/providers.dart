import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
final intensityProvider = StateProvider<double>((ref) => 0.0);
final riskProvider = StateProvider<double>((ref) => 0.0);
final activityProvider = StateProvider<String>((ref) => "SITTING");
final alertLevelProvider = StateProvider<String>((ref) => "STABLE");

// Mock ML function (Member 4 will replace)
Future<double> runRiskInference(List<double> inputs) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return inputs.reduce((a, b) => a + b) / inputs.length / 100;
}