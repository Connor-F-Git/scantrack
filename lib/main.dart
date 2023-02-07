import 'package:flutter/material.dart';
import 'package:scantrack/pages/pages.dart';
import 'package:scantrack/theme/light_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //ProjectKeys constants = ProjectKeys();

  await Supabase.initialize(
    url: ProjectKeys.dbUrl,
    anonKey: ProjectKeys.anonKey,
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
