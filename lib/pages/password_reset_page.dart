import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'snackbar_page.dart';

class PasswordReset extends StatefulWidget {
  const PasswordReset({super.key});

  @override
  State<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  bool _isLoading = false;
  bool _redirecting = false;
  bool _isCodeValid = false;
  bool _isResetDone = false;
  bool _arePasswordsMatching = false;
  late final TextEditingController _emailController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmNewPasswordController;
  late final TextEditingController _authCodeController;

  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _passwordReset() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.auth.resetPasswordForEmail(
        _emailController.text,
        redirectTo: 'https://theprecisionists.com/',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Check your email to reset your password.',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
        ));
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }

    setState(() {
      _isResetDone = true;
      _isLoading = false;
    });
  }

  Future<void> _resetPasswordWithCode() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await supabase.auth.verifyOTP(
        email: _emailController.text,
        token: _authCodeController.text,
        type: OtpType.recovery,
      );
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );
      setState(() {
        _isLoading = false;
      });
      _showResetSnackbar();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      context.showErrorSnackBar(message: error.toString());
    }
  }

  void _showResetSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        'Check your email to confirm account',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.amber,
    ));
    Navigator.pop(context);
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _authCodeController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        Navigator.of(context).popAndPushNamed('/login');
      }
    });
    super.initState();
    _authCodeController.addListener(_validateCode);
    _newPasswordController.addListener(_validatePasswords);
    _confirmNewPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authStateSubscription.cancel();
    _authCodeController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _validateCode() {
    final code = _authCodeController.text;

    setState(() {
      _isCodeValid = code.length == 6 && int.tryParse(code) != null;
    });
  }

  void _validatePasswords() {
    final newPassword = _newPasswordController.text;
    final confirmNewPassword = _confirmNewPasswordController.text;
    setState(() {
      _arePasswordsMatching =
          newPassword == confirmNewPassword && newPassword.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          if (_isResetDone)
            Column(
              children: [
                TextFormField(
                  controller: _authCodeController,
                  decoration:
                      const InputDecoration(labelText: 'Authentication Code'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.length != 6 ||
                        int.tryParse(value) == null) {
                      return 'Authentication code needs to be 6 digits long';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmNewPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'Confirm New Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Visibility(
                    visible: !_arePasswordsMatching &&
                        _newPasswordController.text.isNotEmpty &&
                        _confirmNewPasswordController.text.isNotEmpty,
                    child: const Text(
                      'Passwords must match',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: (_isLoading ||
                    (_isResetDone && (!_isCodeValid || !_arePasswordsMatching)))
                ? null
                : (!_isResetDone ? _passwordReset : _resetPasswordWithCode),
            child: Text(_isLoading ? 'Loading' : 'Submit'),
          ),
        ],
      ),
    );
  }
}
