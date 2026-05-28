import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';

// ================================================================
// LIVE VALUES (Modern Notifier + Stream Adapter Architecture)
// ================================================================

/// Holds the static ML Risk Score (0.0 to 1.0)
class RiskNotifier extends Notifier<double> {
  @override
  double build() => 0.0; 
  
  void setRisk(double value) => state = value; 
}
final riskProvider = NotifierProvider<RiskNotifier, double>(RiskNotifier.new);

/// Used for the Header/Sidebar to display the user's actual name from Firestore
class UserProfileNotifier extends Notifier<String> {
  @override
  String build() => "User";
  
  void setName(String name) => state = name;
}
final userNameProvider = NotifierProvider<UserProfileNotifier, String>(UserProfileNotifier.new);

class DismissNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void setDismissed(bool value) => state = value;
}
final isDismissedProvider = NotifierProvider<DismissNotifier, bool>(DismissNotifier.new);

// 🔥 THE EXERTION ACCUMULATOR
class ExertionNotifier extends Notifier<int> {
  @override
  int build() {
    // Listen to every 10-second tick from the background service
    ref.listen(_stabilizedStreamProvider, (previous, next) {
      final data = next.value;
      if (data == null) return;
      
      final activity = data['activity'] as String? ?? ACTIVITY_SITTING;
      int currentExertion = state;

      // 1. Update the "Stamina Bar" based on the detected action
      if (activity == 'Running' || activity == 'RUNNING') {
        currentExertion += 15;
      } else if (activity == 'Walking' || activity == 'WALKING') {
        currentExertion -= 5;
      } else {
        // Sitting or resting recovers stamina faster
        currentExertion -= 15;
      }

      // 2. Prevent exertion from dropping below zero
      if (currentExertion < 0) {
        currentExertion = 0;
      }

      // Save the new accumulated value
      state = currentExertion;
    });
    
    return 0; // Starts at 0 exertion when app opens
  }
}
final exertionProvider = NotifierProvider<ExertionNotifier, int>(ExertionNotifier.new);


// ================================================================
// BACKGROUND SERVICE STREAMS
// ================================================================

// Carries both live intensity AND an instantly-classified activity label
// updated every 200 ms — no more 10-second wait for the label.
final _liveStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return FlutterBackgroundService()
      .on('updateIntensity')
      .map((event) => {
            'intensity': (event?['intensity'] as num?)?.toDouble() ?? 0.0,
            'activity': event?['activity'] as String? ?? ACTIVITY_SITTING,
          });
});

final _stabilizedStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return FlutterBackgroundService()
      .on('updateStabilizedIntensity')
      .map((event) => {
            'average': (event?['average'] as num?)?.toDouble() ?? 0.0,
            'activity': event?['activity'] as String? ?? ACTIVITY_SITTING,
          });
});

// ================================================================
// UI-FACING PROVIDERS
// ================================================================

final intensityProvider = Provider<double>((ref) {
  final data = ref.watch(_liveStreamProvider).value;
  return data?['intensity'] as double? ?? 0.0;
});

// ✅ NOW INSTANT: reads from the 200ms live stream, not the 10-second window
final activityProvider = Provider<String>((ref) {
  final data = ref.watch(_liveStreamProvider).value;
  return data?['activity'] as String? ?? ACTIVITY_SITTING;
});

final stabilizedIntensityProvider = Provider<double>((ref) {
  final data = ref.watch(_stabilizedStreamProvider).value;
  return (data?['average'] as double?) ?? 0.0;
});

final strainProductProvider = Provider<double>((ref) {
  final risk = ref.watch(riskProvider);
  final data = ref.watch(_stabilizedStreamProvider).value;
  final averageIntensity = data?['average'] as double? ?? 0.0;
  
  return risk * averageIntensity;
});

// 🔥 SMART ALERT ENGINE
final alertLevelProvider = Provider<String>((ref) {
  final risk = ref.watch(riskProvider);
  final exertionLevel = ref.watch(exertionProvider);

  // 1. Calculate Max "Stamina" Limit based on ML Risk Score
  int maxLimit = 1800; // Low Risk (20 mins allowed)
  if (risk >= 0.60) {
    maxLimit = 60;   // High Risk (40 seconds allowed)
  } else if (risk >= 0.30) {
    maxLimit = 300;  // Medium Risk (~3.3 mins allowed)
  }

  // 2. Check Exertion against Limits (100% Capacity)
  if (exertionLevel >= maxLimit) {
    return ALERT_CRITICAL;
  }
  
  // 3. Early Warning threshold (80% Capacity)
  if (exertionLevel >= (maxLimit * 0.8)) {
    return ALERT_ELEVATED;
  }

  return ALERT_STABLE;
});