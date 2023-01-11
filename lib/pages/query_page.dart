import 'package:flutter/material.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({super.key});

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage>
    with AutomaticKeepAliveClientMixin<QueryPage> {
  int _pressCount = 0;
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const Text('Press Count'),
        Text(_pressCount.toString()),
        ElevatedButton(
            onPressed: () {
              setState(() {
                _pressCount++;
              });
            },
            child: const Text('+')),
        const Text('Query Page')
      ],
    );
  }
}
