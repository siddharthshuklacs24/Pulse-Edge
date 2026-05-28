import 'dart:async';
import 'dart:io';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'sensor_math.dart';
import '../core/constants.dart';

// ================================================================
// Called once at app startup (from main.dart)
// Integrated: Permission logic & Notification Channels from Main
// ================================================================
Future<void> initBackgroundService() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      print('Notification permission denied.');
      return;
    }
  }

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'pulse_edge_channel',
    'PulseEdge Background Service',
    description: 'Continuously monitoring your heart health.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false, // Logic from Main
      isForegroundMode: true,
      notificationChannelId: 'pulse_edge_channel',
      initialNotificationTitle: 'PulseEdge',
      initialNotificationContent: 'Monitoring your heart health...',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.dataSync], // Required for Android 15
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

// ================================================================
// BACKGROUND ISOLATE LOGIC
// Integrated: Throttled UI updates and Windowed Activity Classification
// ================================================================
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  final List<double> svmBuffer = [];
  DateTime lastUIUpdate = DateTime.now();
  // Keep a short rolling buffer (last ~1 second of readings) for
  // a slightly smoothed instant label — avoids flickering on single spikes.
  final List<double> instantBuffer = [];
  
  // 1. Listen to raw accelerometer events continuously
  accelerometerEvents.listen((AccelerometerEvent event) {
    // Logic: Use SensorMath class for calculations
    final double rawSVM = SensorMath.calculateSVM(event.x, event.y, event.z);
    final double normalized = SensorMath.normalizeSVM(rawSVM);
    
    svmBuffer.add(normalized);

    // Rolling 1-second smoothing buffer for instant label (~50 samples at 50 Hz)
    instantBuffer.add(normalized);
    if (instantBuffer.length > 50) instantBuffer.removeAt(0);

    // THROTTLE: Send raw spikes to UI 5 times per second for the live chart
    // Also send an instantly-classified activity label each tick.
    final now = DateTime.now();
    if (now.difference(lastUIUpdate).inMilliseconds > 200) {
      final double instantAvg = SensorMath.computeAverage(instantBuffer);
      final String instantActivity = SensorMath.classifyActivity(instantAvg);
      service.invoke('updateIntensity', {
        'intensity': normalized,
        'activity': instantActivity,
      });
      lastUIUpdate = now;
    }
  });

  // 2. Windowed Processing: Every 10 seconds, classify the activity
  Timer.periodic(const Duration(seconds: SENSOR_WINDOW_SECONDS), (timer) {
    if (svmBuffer.isNotEmpty) {
      final double avgIntensity = SensorMath.computeAverage(svmBuffer);
      final String activity = SensorMath.classifyActivity(avgIntensity);

      // Broadcast the stabilized "Activity State" to the UI and Alert logic
      service.invoke('updateStabilizedIntensity', {
        'average': avgIntensity,
        'activity': activity,
      });

      svmBuffer.clear(); // Reset for the next window
    }
  });
}