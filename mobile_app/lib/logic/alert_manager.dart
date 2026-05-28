import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/constants.dart';

class AlertManager {
  // Singleton instance to prevent multiple overlapping alarms
  static final AlertManager _instance = AlertManager._internal();
  factory AlertManager() => _instance;
  AlertManager._internal();

  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  static String _currentAlertLevel = ALERT_STABLE;
  
  // 🔥 NEW: Tracks if the user manually dismissed the current critical alarm
  static bool _isMuted = false;

  // ── Called instantly when Riverpod updates the alert state ─────────────
  static Future<void> processNewReading(String newAlertLevel) async {
    
    // 1. If their vitals drop out of the critical zone, UN-MUTE for the future
    if (newAlertLevel != ALERT_CRITICAL && _isMuted) {
      _isMuted = false;
    }

    // 2. If the state hasn't actually changed, do nothing
    if (_currentAlertLevel == newAlertLevel) return;
    
    _currentAlertLevel = newAlertLevel;

    // 3. Trigger hardware based on the new state
    switch (newAlertLevel) {
      case ALERT_CRITICAL:
        // Only ring the alarm if the user hasn't explicitly muted this event
        if (!_isMuted) {
          await _triggerCriticalAlert();
        }
        break;
      case ALERT_ELEVATED:
        await _triggerElevatedAlert();
        break;
      case ALERT_STABLE:
      default:
        await dismissAlert(isManual: false); // Turn everything off safely
        break;
    }
  }

  // ── 🚨 CRITICAL: Loops an audio alarm and vibrates continuously ────────
  static Future<void> _triggerCriticalAlert() async {
    print("🚨 AlertManager: Firing CRITICAL hardware triggers!");
    
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      // Harsh SOS pattern that repeats indefinitely (repeat: 0)
      Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500], repeat: 0);
    }

    // Play the audio file on an infinite loop
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audio/critical_alarm.mp3'));
  }

  // ── ⚠️ ELEVATED: Just a quick haptic bump (no audio) ───────────────────
  static Future<void> _triggerElevatedAlert() async {
    print("⚠️ AlertManager: Firing ELEVATED hardware triggers (Haptic Bump)");
    
    // Stop any audio that might have been playing
    await _audioPlayer.stop();
    Vibration.cancel(); // Ensure any previous critical vibrations are cleared

    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 800, amplitude: 200);
    }
  }

  // ── ✅ DISMISS / STABLE: Turn everything off ───────────────────────────
  // If the user clicks the UI button, isManual defaults to true.
  static Future<void> dismissAlert({bool isManual = true}) async {
    print("✅ AlertManager: Stopping hardware (Manual Dismiss: $isManual)");
    
    if (isManual) {
      _isMuted = true; // Mute the alarm so the next 10s tick doesn't restart it
    } else {
      _currentAlertLevel = ALERT_STABLE;
      _isMuted = false;
    }
    
    // Cancel any ongoing vibration pattern
    Vibration.cancel();
    
    // Stop the audio player
    await _audioPlayer.stop();
  }
}