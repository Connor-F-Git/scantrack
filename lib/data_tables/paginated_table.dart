import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:scantrack/data_tables/supabase_handler.dart';
import 'package:scantrack/pages/snackbar_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageTable extends StatefulWidget {
  const PageTable({super.key});

  @override
  State<PageTable> createState() => _PageTableState();
}

class _PageTableState extends State<PageTable> {
  User? _user;
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
        print("here ${snapshot.data.toString()}");
        if (snapshot.hasData == null &&
            snapshot.connectionState == ConnectionState.none) {}
        print("here1 ${snapshot.data.toString()}");

        /*Map<String, dynamic> data = snapshot.data;
        List<DataColumn> dataCols = [];

        if (snapshot.data != null) {
          for (var property in data.keys) {
            dataCols.add(DataColumn(label: Text(property)));
          }
        }
        */
        List<DataColumn> dataCols = [
          DataColumn(label: Text('id')),
          DataColumn(label: Text('createdAt')),
          DataColumn(label: Text('filename')),
          DataColumn(label: Text('lastUpdated')),
          DataColumn(label: Text('location')),
          DataColumn(label: Text('uploader')),
        ];

        /*
        List<DataRow> dataRows = [];
        for (var row in snapshot.data!) {
          List<DataCell> curRow = [];
          for (var cell in row) {
            curRow.add(cell);
          }
          dataRows.add(DataRow(cells: curRow));
        }
        */

        List<DataRow> dataRows = [
          DataRow(cells: [
            DataCell(Text('1,1')),
            DataCell(Text('1,2')),
            DataCell(Text('1,3')),
            DataCell(Text('1,4')),
            DataCell(Text('1,5')),
            DataCell(Text('1,6')),
          ]),
          DataRow(cells: [
            DataCell(Text('2,1')),
            DataCell(Text('2,2')),
            DataCell(Text('2,3')),
            DataCell(Text('2,4')),
            DataCell(Text('2,5')),
            DataCell(Text('2,6')),
          ]),
        ];

        return DataTable(columns: dataCols, rows: dataRows);
        // return ListView.builder(
        //   itemCount: snapshot.data?.length ?? 0,
        //   itemBuilder: (context, index) {
        //     List<DataRow> _data = [];
        //     for (var element in snapshot.data![index]) {
        //       List<DataCell> curRowCells = [];
        //       for (var value in element.values) {
        //         curRowCells.add(DataCell(value));
        //       }
        //       DataRow curRow = DataRow(cells: curRowCells);

        //       _data.add(curRow);
        //     }
        //     return _data;
        // return Container(
        //   height: 150,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Container(
        //         width: 200,
        //         child: Center(
        //           child: Text(snapshot.data![index]['filename']),
        //         ),
        //       ),
        //       IconButton(
        //           icon: const Icon(Icons.done),
        //           onPressed: () {
        //             supaBaseHandler.updateData(
        //                 snapshot.data[index]['id'], true);
        //           }),
        //       IconButton(
        //           icon: const Icon(Icons.delete),
        //           onPressed: () {
        //             supaBaseHandler.deleteData(snapshot.data[index]['id']);
        //             setState(() {});
        //           }),
        //     ],
        //   ),
        // );
        //   },
        // );
      }),
    );
  }
}
