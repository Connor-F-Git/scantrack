import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
