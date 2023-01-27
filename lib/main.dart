import 'package:flutter/material.dart';
import 'package:scantrack/pages/pages.dart';
import 'package:scantrack/theme/light_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tbausrsfiefpjlzkmfbk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6'
        'InRiYXVzcnNmaWVmcGpsemttZmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzI3NTc5N'
        'DUsImV4cCI6MTk4ODMzMzk0NX0.Sw4IzrzQhHERkjOABHiXUp7joke_vQzlIZXWqCFiL8Y',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TPI Scan Tracking',
      theme: getLightTheme(),
      initialRoute: '/splash',
      routes: {
        '/': (context) => const MyHomePage(),
        '/login': (context) => const LoginPage(),
        '/splash': (context) => const SplashPage(),
      },
    );
  }
}
