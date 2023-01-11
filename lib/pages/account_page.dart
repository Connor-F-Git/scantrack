import 'package:flutter/material.dart';
import 'package:scantrack/pages/snackbar_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with AutomaticKeepAliveClientMixin<AccountPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      children: [
        Padding(padding: EdgeInsets.all(10.0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Email: '),
            Text(supabase.auth.currentUser!.email.toString())
          ],
        ),
        Padding(padding: EdgeInsets.all(10.0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // TODO: get number of files on loading into application
          children: [Text('Files in Database: '), Text('13')],
        )
      ],
    );
  }
}
