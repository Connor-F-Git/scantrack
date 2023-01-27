import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:scantrack/data_tables/supabase_handler.dart';
import 'package:scantrack/shared/loading_animation.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage>
    with AutomaticKeepAliveClientMixin<FilePage> {
  @override
  bool get wantKeepAlive => true;
  bool _loading = false;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;
  final SupaBaseHandler _supaBaseHandler = SupaBaseHandler();
  List<DataColumn2> _dataColumns = [];
  List<DataRow2> _dataRows = [];
  late PaginatedSource _paginatedSource;
  bool isNoFiles = false;

  Widget determineLoading() {
    if (_loading) {
      return const LoadAnimation();
    } else if (isNoFiles) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Your account has no file information in the database.",
            style: TextStyle(fontSize: 20),
          ),
          Text(
            "Tip: Navigate to the 'Paths' tab to upload file information",
            style: TextStyle(
                color: Color.fromARGB(255, 136, 136, 136), fontSize: 14),
          ),
        ],
      );
    } else {
      return PaginatedDataTable2(
          sortArrowIcon: Icons.arrow_downward,
          sortAscending: _sortAscending,
          sortColumnIndex: _sortColumnIndex,
          columns: _dataColumns,
          source: _paginatedSource);
    }
  }

  Widget refreshButton() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            _loading = true;
          });
          getTableData().then((value) {
            _dataColumns = [];
            _dataRows = [];
            dataHandler(value);
          });
          setState(() {
            _loading = false;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [Icon(Icons.refresh), Text("Refresh")],
        ));
  }

  Future<List?> getTableData() async {
    return _supaBaseHandler.readData(context);
  }

  void sort<T>(
    Comparable<T> Function(String d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _paginatedSource.sort<T>(getField, ascending, columnIndex);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void dataHandler(List<dynamic>? data) {
    if (data!.isNotEmpty) {
      // Populate Columns
      for (var key in data[0].keys) {
        _dataColumns.add(DataColumn2(
          label: Text(key.toString()),
          onSort: (columnIndex, ascending) =>
              sort<String>((d) => d, columnIndex, ascending),
        ));
      }

      // Populate Rows
      for (var row in data) {
        List<DataCell> curRow = [];
        // get index of date rows
        for (var val in row.values) {
          String parsedVal = val.toString();
          bool isCreatedAt = (row.keys.firstWhere((k) => row[k] == val,
                  orElse: (() => val.toString()))) ==
              'created_at';
          bool isLastUpdated = (row.keys.firstWhere((k) => row[k] == val,
                  orElse: (() => val.toString()))) ==
              'last_updated';
          if ((isCreatedAt || isLastUpdated) && (val != null)) {
            curRow.add(DataCell(
                Text(DateFormat("MM/dd/yyyy").format(DateTime.parse(val)))));
          } else {
            curRow.add(DataCell(Text(parsedVal)));
          }
        }
        _dataRows.add(DataRow2(cells: curRow));
      }

      // assign data rows to table source
      _paginatedSource = PaginatedSource(_dataRows);
      print(_paginatedSource.dataRows.first.cells.length.toString());
      print("columns");
      print(_dataColumns);
      setState(() {
        isNoFiles = false;
        _loading = false;
      });
    } else {
      setState(() {
        isNoFiles = true;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    _loading = true;
    getTableData().then((data) {
      dataHandler(data);
      isNoFiles = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _paginatedSource.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        children: [Expanded(child: determineLoading()), refreshButton()],
      ),
    );
  }
}

class PaginatedSource extends DataTableSource {
  List<DataRow> dataRows;
  PaginatedSource(this.dataRows);

  void sort<T>(Comparable<T> Function(String d) getField, bool ascending,
      int sortColumnIndex) {
    dataRows.sort((a, b) {
      final aValue = a.cells[sortColumnIndex].child.toString();
      final bValue = b.cells[sortColumnIndex].child.toString();
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
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
