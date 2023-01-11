import 'package:flutter/material.dart';
import 'package:scantrack/pages/snackbar_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaBaseHandler {
  addData(String task, bool status, context) async {
    try {
      await Supabase.instance.client
          .from('todotable')
          .upsert({'task': task, 'status': status});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Saved the Task'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error saving task'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<List?> readData(context) async {
    // var response = await client.from("todotable").select().order('task', ascending: true).execute();
    print('Read Data');
    try {
      var response = await supabase.from('files').select('*');
      print('Response Data ${response}');
      final dataList = response;
      return dataList;
    } catch (e) {
      print('Response Error ${e}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error occured while getting Data'),
        backgroundColor: Colors.red,
      ));
      return null;
    }
  }

  updateData(int id, bool statusval) async {
    await Supabase.instance.client
        .from('files')
        .upsert({'id': id, 'uploader': statusval});
  }

  deleteData(int id) async {
    await Supabase.instance.client.from('files').delete().match({'id': id});
  }
}
