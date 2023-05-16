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
  Widget build(BuildContext context) {
    super.build(context);
    final currentUser = supabase.auth.currentUser;
    final lastSign =
        currentUser != null ? supabase.auth.currentUser?.updatedAt : '';
    final lastSignIn = lastSign!.isNotEmpty
        ? DateFormat('M/d/y hh:mm aaa')
            .format(DateTime.parse(lastSign).toLocal())
        : 'Error';
    if (currentUser != null) {
      return Center(
        child: ListView(
          shrinkWrap: true,
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
              children: [const Text('Last Login: '), Text(lastSignIn)],
            ),
            const Padding(padding: EdgeInsets.all(10.0)),
            TextButton(onPressed: _signOut, child: const Text('Sign Out'))
          ],
        ),
      );
    } else {
      return const LoadAnimation();
    }
  }
}
