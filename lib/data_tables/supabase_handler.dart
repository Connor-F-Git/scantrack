import 'package:flutter/material.dart';
import 'package:scantrack/pages/snackbar_page.dart';

class SupaBaseHandler {
  Future<List?> getEmails(context) async {
    try {
      var response = await supabase.rpc('get_email_list');
      final dataList = response;
      return dataList;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error occured while getting List of Users'),
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
      // TODO: MASSIVE OVERHAUL OF THIS FUNCTION
      //       create function in supabase that accepts the following parameters:
      //       1. an array of text that could possibly be empty
      //       2. text that may be empty
      //       3. first date that must be earlier than the second
      //       4. second date that must be later than the first
      // var response = await supabase
      //     .from('files')
      //     .select('filename, created_at, uploader')
      //     .eq(
      //         'user_id',
      //         supabase.auth.currentUser!.id
      //             .toString()) // TODO: edit this to accept multiple users
      //     .ilike('filename', '%$textFilter%')
      //     .gte('created_at', afterDate.isNotEmpty ? afterDate : '01/01/1970')
      //     .lte('created_at', beforeDate.isNotEmpty ? beforeDate : '12/31/2222');
      var response = await supabase.rpc('search_files', params: {
        'uploaders': queryFilters['uploaders'],
        'searchtext': textFilter,
        'afterdate': afterDate.isNotEmpty ? afterDate : '01/01/1970',
        'beforedate': beforeDate.isNotEmpty ? beforeDate : '12/31/2222'
      });
      print("RESPONSE");
      print(response.toString());
      final dataList = response;
      return dataList;
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error occured while getting Data'),
        backgroundColor: Colors.red,
      ));
      return null;
    }
  }

  Future<Map<String, int>?> readUsersFileCount(
      context, DateTime start, DateTime end) async {
    try {
      var response = await supabase.rpc('get_file_counts_by_user',
          params: {'start_date': start, 'end_date': end});
      final dataList = response;
      return dataList;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error occured while getting Data'),
        backgroundColor: Colors.red,
      ));
    }
    return null;
  }
}
