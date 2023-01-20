import 'package:flutter/material.dart';
import 'package:scantrack/pages/snackbar_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaBaseHandler {
  addData(String filename, String createdAt, String lastUpdated,
      String? uploader, context) async {
    try {
      await Supabase.instance.client.from('files').upsert({
        'filename': filename,
        'created_at': createdAt,
        'last_updated': lastUpdated,
        'uploader': uploader,
        'user_id': supabase.auth.currentUser?.id
      });
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
      String fullCompare = r"";
      for (String path in paths) {
        fullCompare += "$path,";
      }

      // remove the ending comma
      fullCompare = fullCompare.substring(0, fullCompare.length - 1);

      //print(fullCompare);
      var response = await supabase
          .from("files")
          .select("filename") //"filename, user_id")
          .eq("user_id", supabase.auth.currentUser!.id)
          .filter('filename', 'in', "($fullCompare)");
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
