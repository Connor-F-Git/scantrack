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
  late PaginatedSource _paginatedSource;

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  DateFormat readableFormat = DateFormat('MM-dd-yyyy');

  bool _loading = false;

  Widget determineLoading() {
    if (!_loading) {
      return PaginatedDataTable2(
          autoRowsToHeight: true,
          sortArrowIcon: Icons.arrow_downward,
          sortAscending: _sortAscending,
          sortColumnIndex: _sortColumnIndex,
          columns: cols,
          source: _paginatedSource);
    } else {
      return const LoadAnimation();
    }
  }

  Widget isTableEmpty() {
    if (widget.queryInfo!.isNotEmpty) {
      return determineLoading();
    } else if (cols.toString() == '[]') {
      return const Text(
        "There are no results that match your query.",
        style: TextStyle(fontSize: 20),
      );
    } else {
      return const LoadAnimation();
    }
  }

  void sort<T>(Comparable<T> Function(String d) getField, int columnIndex,
      bool ascending, String columnKey) {
    _paginatedSource.sort<T>(getField, ascending, columnIndex, columnKey);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void buildTableInfo(List<dynamic> data) {
    if (data.isNotEmpty) {
      for (var key in data.first.keys) {
        cols.add(DataColumn2(
          label: Text(key.toString()),
          onSort: (columnIndex, ascending) =>
              sort<String>((d) => d, columnIndex, ascending, key),
        ));
      }
      for (var row in data) {
        List<DataCell> curRow = [];
        for (var cell in row.values) {
          bool isCreatedAt = (row.keys.firstWhere((k) => row[k] == cell,
                  orElse: (() => cell.toString()))) ==
              'created_at';
          if (isCreatedAt) {
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
    setState(() {
      _loading = true;
    });
    _paginatedSource = PaginatedSource(rows);
    buildTableInfo(widget.queryInfo!);
    setState(() {
      _loading = false;
    });
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

class PaginatedSource extends DataTableSource {
  List<dynamic>? dataRows;
  PaginatedSource(this.dataRows);

  void sort<T>(Comparable<T> Function(String d) getField, bool ascending,
      int sortColumnIndex, String columnKey) {
    dataRows!.sort((a, b) {
      dynamic aValue;
      dynamic bValue;
      if (columnKey == 'created_at') {
        String aChild = a.cells[sortColumnIndex].child.toString();
        String bChild = b.cells[sortColumnIndex].child.toString();
        aChild = aChild.substring(6, aChild.length - 2);
        bChild = bChild.substring(6, bChild.length - 2);
        aValue = DateFormat('MM-dd-yyyy').parse(aChild);
        bValue = DateFormat('MM-dd-yyyy').parse(bChild);
      } else {
        aValue = a.cells[sortColumnIndex].child.toString();
        bValue = b.cells[sortColumnIndex].child.toString();
      }
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    return dataRows![index];
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dataRows!.length;

  @override
  int get selectedRowCount => 0;
}
