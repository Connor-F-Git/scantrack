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
      var response = await supabase.rpc('search_files', params: {
        'uploaders': queryFilters['uploaders'],
        'searchtext': textFilter,
        'afterdate': afterDate.isNotEmpty ? afterDate : '01/01/1970',
        'beforedate': beforeDate.isNotEmpty ? beforeDate : '12/31/2222'
      });
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

  Future<List?> queryDbFileCount(
      context, Map<String, dynamic> queryFilters) async {
    try {
      String textFilter = queryFilters['text'];
      textFilter =
          textFilter.replaceAllMapped(RegExp(r"(\(|\))"), (match) => "~");
      String afterDate = queryFilters['after'];
      String beforeDate = queryFilters['before'];
      var response = await supabase.rpc('search_file_count', params: {
        'uploaders': queryFilters['uploaders'],
        'searchtext': textFilter,
        'afterdate': afterDate.isNotEmpty ? afterDate : '01/01/1970',
        'beforedate': beforeDate.isNotEmpty ? beforeDate : '12/31/2222'
      });
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
