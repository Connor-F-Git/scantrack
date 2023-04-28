import 'package:flutter/material.dart';
import 'package:scantrack/pages/snackbar_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaBaseHandler {
  String userId = supabase.auth.currentUser!.id;
  String? userEmail = supabase.auth.currentUser?.email;
  addData(List<String> dataFiles, context) async {
    try {
      await supabase.rpc('add_files',
          params: {'userfiles': dataFiles, 'upl': userEmail, 'uid': userId});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error saving task'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<List?> checkFiles(
    context,
    List<String> paths,
  ) async {
    try {
      // response = all files on both the 'paths' list and db
      var response =
          await supabase.rpc('get_check_files', params: {'userfiles': paths});

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

  Future<List?> readData(context) async {
    try {
      var response = await supabase
          .from('files')
          .select('filename, created_at, last_updated, uploader')
          .eq('user_id', userId);
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

  Future<List?> queryDb(context, Map<String, dynamic> queryFilters) async {
    try {
      String textFilter = queryFilters['text'];
      textFilter =
          textFilter.replaceAllMapped(RegExp(r"(\(|\))"), (match) => "~");
      String afterDate = queryFilters['after'];
      String beforeDate = queryFilters['before'];
      var response = await supabase
          .from('files')
          .select('filename, created_at, last_updated, uploader')
          .eq('user_id', userId)
          .like('filename', '%$textFilter%')
          .gte('created_at', afterDate.isNotEmpty ? afterDate : '01/01/1970')
          .lte('created_at', beforeDate.isNotEmpty ? beforeDate : '12/31/2222');

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

  Future<int> readUserFileCount(context) async {
    try {
      var response = await supabase.from('files').select('COUNT(*)');
      final dataList = response;
      return dataList;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error occured while getting Data'),
        backgroundColor: Colors.red,
      ));
      return 0;
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
