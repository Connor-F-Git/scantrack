import 'package:flutter/material.dart';

ThemeData getLightTheme() {
  return ThemeData(
      primaryColor: const Color.fromARGB(255, 9, 129, 13),
      backgroundColor: Colors.green,
      colorScheme: const ColorScheme(
          background: Colors.green,
          brightness: Brightness.light,
          error: Colors.red,
          onBackground: Colors.black,
          onError: Colors.black,
          onPrimary: Color.fromARGB(255, 255, 255, 255),
          onSecondary: Color.fromARGB(255, 14, 117, 4),
          onTertiary: Color.fromARGB(255, 93, 194, 93),
          onSurface: Colors.greenAccent,
          // Primary, Secondary, Surface
          primary: Colors.green,
          secondary: Colors.lightGreen,
          surface: Color.fromARGB(255, 4, 46, 5)));
}
