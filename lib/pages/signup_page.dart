import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'snackbar_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isLoading = false;
  bool _redirecting = false;
  bool _isPasswordMatched = false;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        emailRedirectTo: 'https://theprecisionists.com/',
      );
      // ignore: unused_local_variable
      final Session? session = res.session;
      // ignore: unused_local_variable
      final User? user = res.user;
      if (mounted) {
        _passwordController.clear();
        _confirmPasswordController.clear();
        _emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Check your email to confirm account',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
        ));
        Navigator.pop(context);
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordMatched =
          _passwordController.text == _confirmPasswordController.text &&
              _passwordController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).popAndPushNamed('/login');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
          ),
          Visibility(
            visible: !_isPasswordMatched &&
                _passwordController.text.isNotEmpty &&
                _confirmPasswordController.text.isNotEmpty,
            child: const Text(
              'Passwords must match',
              style: TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isPasswordMatched && !_isLoading ? _signUp : null,
            child: Text(_isLoading ? 'Loading' : 'Submit'),
          ),
        ],
      ),
    );
  }
}
