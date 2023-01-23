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

  final _fileCountController = TextEditingController();

  bool _loading = false;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });

    if (mounted && supabase.auth.currentUser != null) {
      final userId = supabase.auth.currentUser!.id;
      final countData = await supabase
          .from('files')
          .select(
            'id',
            const FetchOptions(
              count: CountOption.exact,
            ),
          )
          .eq('user_id', userId);
      _fileCountController.text = countData.count.toString();
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
    _fileCountController.dispose();
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
            children: [const Text('Last Login: '), Text(lastSignIn.toString())],
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [const Text('User ID: '), Text(currentUser.id)],
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [const Text('# of Files in DB: '), countText()],
          ),
          const Padding(padding: EdgeInsets.all(10.0)),
          TextButton(onPressed: _signOut, child: const Text('Sign Out'))
        ],
      );
    } else {
      return const LoadAnimation();
    }
  }

  Widget countText() {
    if (_loading) {
      return const Text('Loading...');
    } else {
      return Text(_fileCountController.text.isEmpty
          ? 'No Files in DB'
          : _fileCountController.text);
    }
  }
}
