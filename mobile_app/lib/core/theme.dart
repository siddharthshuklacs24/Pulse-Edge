import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF060B18),
    primaryColor: const Color(0xFF00E5FF),
    fontFamily: 'Poppins',
  );
}

const gradientBG = LinearGradient(
  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);