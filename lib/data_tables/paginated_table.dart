import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:scantrack/data_tables/supabase_handler.dart';
import 'package:scantrack/shared/loading_animation.dart';

class PageTable extends StatefulWidget {
  const PageTable({super.key});

  @override
  State<PageTable> createState() => _PageTableState();
}

class _PageTableState extends State<PageTable> {
  late SupaBaseHandler supaBaseHandler = SupaBaseHandler();
  String newValue = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: supaBaseHandler.readData(context),
      builder: ((context, AsyncSnapshot snapshot) {
        // ignore: unnecessary_null_comparison
        if (snapshot.hasData == null &&
            snapshot.connectionState == ConnectionState.none) {}

        if (snapshot.hasData) {
          List<DataColumn> dataCols = [];

          for (var key in snapshot.data[0].keys) {
            dataCols.add(DataColumn(label: Text(key.toString())));
          }

          List<DataRow> dataRows = [];
          for (var row in snapshot.data!) {
            List<DataCell> curRow = [];
            for (var val in row.values) {
              curRow.add(DataCell(Text(val.toString())));
            }
            dataRows.add(DataRow(cells: curRow));
          }

          return DataTable(columns: dataCols, rows: dataRows);
        } else {
          return const LoadAnimation();
        }
      }),
    );
  }
}
