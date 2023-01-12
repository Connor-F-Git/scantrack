import 'package:flutter/material.dart';
import 'package:scantrack/pages/snackbar_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaBaseHandler {
  addData(String filename, DateTime createdAt, DateTime lastUpdated,
      String location, String uploader, context) async {
    try {
      await Supabase.instance.client.from('files').upsert({
        'filename': filename,
        'created_at': createdAt,
        'last_updated': lastUpdated,
        'location': location,
        'uploader': uploader,
        'user_id': supabase.auth.currentUser?.id
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Uploaded the File(s)'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error saving task'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<List?> readData(context) async {
    try {
      var response = await supabase.from('files').select('*');
      final dataList = response;
      return dataList;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error occured while getting Data'),
        backgroundColor: Colors.red,
      ));
      return null;
    }
  }

  Future<List?> readUserFileCount(context) async {
    try {
      var response = await supabase.from('files').select('*');
      final dataList = response;
      return dataList;
    } catch (e) {
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
