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
  bool _sortAscending = true;
  // ignore: unused_field
  int? _sortColumnIndex = 0;

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
            dataCols.add(DataColumn2(
                label: Text(key.toString()),
                onSort: (columnIndex, ascending) {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = !_sortAscending;
                  // TODO: figure out how to sort
                  setState(() {});
                }));
          }

          List<DataRow2> dataRows = [];
          for (var row in snapshot.data!) {
            List<DataCell> curRow = [];
            for (var val in row.values) {
              curRow.add(DataCell(Text(val.toString())));
            }
            dataRows.add(DataRow2(cells: curRow));
          }
          PaginatedSource rowSource = PaginatedSource(dataRows);
          return PaginatedDataTable2(
            columns: dataCols,
            source: rowSource,
            minWidth: 600.0,
          );
        } else {
          return const LoadAnimation();
        }
      }),
    );
  }
}

class PaginatedSource extends DataTableSource {
  List<DataRow> dataRows;
  PaginatedSource(this.dataRows);

  List<DataRow2> sort(List<DataRow2> data, sortColumnIndex) {
    data.sort((a, b) => data.length.compareTo(sortColumnIndex));
    return data;
  }

  @override
  DataRow? getRow(int index) {
    return dataRows[index];
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dataRows.length;

  @override
  int get selectedRowCount => 0;
}
