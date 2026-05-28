import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(top: -120, right: -80, child: _glow(const Color(0xFF2563EB))),
          Positioned(bottom: -140, left: -80, child: _glow(const Color(0xFF06B6D4))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pulse Edge", style: TextStyle(fontSize: 16, color: Colors.white60, letterSpacing: 1.5)),
                  const SizedBox(height: 40),
                  const Text("Build awareness\nof your body.", style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, height: 1.2)),
                  const SizedBox(height: 20),
                  const Text("Track your activity.\nReduce risk.\nStay in control of your health.", style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.6)),
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.25), blurRadius: 80, spreadRadius: 20)],
                      ),
                      child: Image.asset("assets/images/pulse_edge_logo.png", height: 180, errorBuilder: (c, e, s) => const Icon(Icons.favorite, size: 100, color: Colors.cyanAccent)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ).copyWith(
                            elevation: ButtonStyleButton.allOrNull(0.0),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF06B6D4)]),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(maxWidth: 250, minHeight: 50),
                              child: const Text("Create Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
child: RichText(
  text: const TextSpan(
    text: "Already have an account? ",
    style: TextStyle(color: Colors.white54, fontSize: 14),
    children: [
      TextSpan(
        text: "Log In",
        style: TextStyle(
          color: Color(0xFF06B6D4),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF06B6D4),
        ),
      ),
    ],
  ),
),                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color) {
    return Container(
      height: 320, width: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent], radius: 0.8),
      ),
    );
  }
}