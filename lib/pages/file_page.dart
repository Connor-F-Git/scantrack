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
  final List<DataColumn2> _dataColumns = [];
  final List<DataRow2> _dataRows = [];
  late PaginatedSource _paginatedSource;

  Widget determineLoading() {
    if (_loading) {
      return const LoadAnimation();
    } else {
      return PaginatedDataTable2(
          sortArrowIcon: Icons.arrow_downward,
          sortAscending: _sortAscending,
          sortColumnIndex: _sortColumnIndex,
          columns: _dataColumns,
          source: _paginatedSource);
    }
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

  @override
  void initState() {
    _loading = true;
    getTableData().then((data) {
      // Populate Columns
      for (var key in data![0].keys) {
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
      setState(() {
        _loading = false;
      });
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
        children: [
          Expanded(child: determineLoading()),
        ],
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
