import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADDED

import 'services/background_service.dart';
import 'services/local_db.dart';
import 'screens/assessment_form.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: PulseEdgeApp(),
    ),
  );

  _initServices();
}

Future<void> _initServices() async {
  try {
    await Permission.notification.request();
    await initBackgroundService();
  } catch (e) {
    debugPrint("Service Init Error: $e");
  }
}

class PulseEdgeApp extends StatelessWidget {
  const PulseEdgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse Edge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      
      // We route to AuthWrapper instead of hardcoding a screen
      home: const AuthWrapper(),
      
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/form': (_) => const AssessmentFormScreen(),
      },
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child!,
        );
      },
    );
  }
}

// 🔥 THE TRAFFIC CONTROLLER 🔥
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If Firebase is still checking...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
          );
        }
        // If User is Logged In -> Go to Dashboard
        if (snapshot.hasData) {
          return const DashboardScreen();
        }
        // If User is NOT Logged In -> Show Onboarding
        return const OnboardingScreen();
      },
    );
  }
}