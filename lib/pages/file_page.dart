import 'package:flutter/material.dart';
import 'package:scantrack/data_tables/paginated_table.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage>
    with AutomaticKeepAliveClientMixin<FilePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        children: const [
          Text(
            "File Information You Uploaded",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30.0),
          ),
          Expanded(child: PageTable()),
        ],
      ),
    );
  }
}
