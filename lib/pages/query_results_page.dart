import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  DateFormat readableFormat = DateFormat('MM-dd-yyyy');

  Widget isTableEmpty() {
    if (cols.isNotEmpty) {
      return DataTable2(
          sortAscending: _sortAscending,
          sortColumnIndex: _sortColumnIndex,
          columns: cols,
          rows: rows);
    } else if (cols.toString() == '[]') {
      return const Text(
        "There are no results that match your query.",
        style: TextStyle(fontSize: 20),
      );
    } else {
      return const LoadAnimation();
    }
  }

  void buildTableInfo(List<dynamic> data) {
    if (data.isNotEmpty) {
      for (var key in data.first.keys) {
        cols.add(DataColumn2(
          label: Text(key.toString()),
          onSort: (columnIndex, ascending) {
            rows.sort(((a, b) {
              dynamic aValue;
              dynamic bValue;
              if ((key == 'created_at') || (key == 'last_updated')) {
                String aChild = a.cells[columnIndex].child.toString();
                String bChild = b.cells[columnIndex].child.toString();
                aChild = aChild.substring(4, aChild.length - 1);
                bChild = bChild.substring(4, bChild.length - 1);
                aValue = DateFormat('M-d-y').parse(aChild);
                bValue = DateFormat('M-d-y').parse(bChild);
              } else {
                aValue = a.cells[columnIndex].child.toString();
                bValue = b.cells[columnIndex].child.toString();
              }
              return _sortAscending
                  ? Comparable.compare(aValue, bValue)
                  : Comparable.compare(bValue, aValue);
            }));
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = !_sortAscending;
            });
          },
        ));
      }
      for (var row in data) {
        List<DataCell> curRow = [];
        for (var cell in row.values) {
          bool isCreatedAt = (row.keys.firstWhere((k) => row[k] == cell,
                  orElse: (() => cell.toString()))) ==
              'created_at';
          bool isLastUpdated = (row.keys.firstWhere((k) => row[k] == cell,
                  orElse: (() => cell.toString()))) ==
              'last_updated';
          if (isCreatedAt || isLastUpdated) {
            // null check
            String nullCheckedDate = cell != null
                ? readableFormat.format(DateTime.parse(cell.toString()))
                : 'null';
            curRow.add(DataCell(
                // convert the long date format into a readable date format
                Text(nullCheckedDate)));
          } else {
            curRow.add(DataCell(Text(cell.toString())));
          }
        }
        rows.add(DataRow2(cells: curRow, specificRowHeight: 100));
      }
    }
  }

  @override
  void initState() {
    buildTableInfo(widget.queryInfo!);
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
