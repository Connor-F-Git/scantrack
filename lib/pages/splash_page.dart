import 'package:flutter/material.dart';
import 'package:scantrack/pages/snackbar_page.dart';
import 'package:scantrack/shared/loading_animation.dart';

Future<void> determinePath(context) async {
  await Future.delayed(const Duration(seconds: 2));
  if (supabase.auth.currentUser?.role == 'authenticated') {
    Navigator.of(context).popAndPushNamed('/');
  } else {
    Navigator.of(context).popAndPushNamed('/login');
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  LoadAnimation loadingAnimation = const LoadAnimation();
  @override
  void initState() {
    super.initState();
    determinePath(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loadingAnimation //LoadAnimation(),
            ],
          ),
        ),
      ),
    );
  }
}
