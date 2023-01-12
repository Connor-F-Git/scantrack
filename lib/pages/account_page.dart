import 'package:flutter/material.dart';
import 'package:scantrack/pages/snackbar_page.dart';
import 'package:scantrack/shared/loading_animation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with AutomaticKeepAliveClientMixin<AccountPage> {
  @override
  bool get wantKeepAlive => true;

  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _avatarUrl;
  var _loading = false;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    if (mounted && supabase.auth.currentUser != null) {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single() as Map;
      _usernameController.text = (data['username'] ?? '') as String;
      _websiteController.text = (data['website'] ?? '') as String;
      _avatarUrl = (data['avatar_url'] ?? '') as String;
    }

    setState(() {
      _loading = false;
    });
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final userName = _usernameController.text;
    final website = _websiteController.text;
    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'username': userName,
      'website': website,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        context.showSnackBar(message: 'Successfully updated profile!');
      }
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpeted error occurred');
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentUser = supabase.auth.currentUser;
    final lastSign = supabase.auth.currentUser?.lastSignInAt;
    final lastSignIn = DateFormat('M/d/y hh:mm aaa')
        .format(DateTime.parse(lastSign!).toLocal());
    if (currentUser != null) {
      return ListView(
        children: [
          const Padding(padding: EdgeInsets.all(10.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Email: '),
              Text(currentUser.email.toString())
            ],
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            // TODO: get number of files on loading into application
            children: [const Text('Last Login: '), Text(lastSignIn.toString())],
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
          TextButton(onPressed: _signOut, child: const Text('Sign Out'))
        ],
      );
    } else {
      return const LoadAnimation();
    }
  }
}
