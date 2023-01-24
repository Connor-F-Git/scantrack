import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:scantrack/shared/loading_animation.dart';

class QueryResults extends StatefulWidget {
  const QueryResults({super.key, required this.queryInfo});

  final List<dynamic>? queryInfo;

  @override
  State<QueryResults> createState() => _QueryResultsState();
}

class _QueryResultsState extends State<QueryResults> {
  List<DataColumn2> cols = [];

  List<DataRow2> rows = [];

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  Widget isTableEmpty() {
    if (cols.isNotEmpty) {
      return DataTable2(
          sortAscending: _sortAscending,
          sortColumnIndex: _sortColumnIndex,
          columns: cols,
          rows: rows);
    } else {
      return LoadAnimation();
    }
  }

  @override
  void initState() {
    print("QUERY INFO BELOW:");
    print(widget.queryInfo.toString());
    if (widget.queryInfo != null) {
      for (var key in widget.queryInfo!.first.keys) {
        cols.add(DataColumn2(
          label: Text(key.toString()),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = !_sortAscending;
              rows.sort(((a, b) {
                if (!_sortAscending) {
                  return a.cells[columnIndex].child
                      .toString()
                      .compareTo(b.cells[columnIndex].child.toString());
                } else {
                  return b.cells[columnIndex].child
                      .toString()
                      .compareTo(a.cells[columnIndex].child.toString());
                }
              }));
            });
          },
        ));
      }
      for (var row in widget.queryInfo!) {
        List<DataCell> curRow = [];
        for (var cell in row.values) {
          curRow.add(DataCell(Text(cell.toString())));
        }
        rows.add(DataRow2(cells: curRow));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Results")),
      body: Center(
        child: isTableEmpty(),
      ),
    );
  }
}
