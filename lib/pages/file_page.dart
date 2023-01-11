import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
//import 'package:scantrack/data_tables/fetched_files.dart';
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
    return PageTable();
  }
}
