import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scantrack/data_tables/supabase_handler.dart';
import 'package:scantrack/pages/snackbar_page.dart';
import 'package:scantrack/shared/loading_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' as io;

class MonitoredPathsPage extends StatefulWidget {
  const MonitoredPathsPage({super.key});

  @override
  State<MonitoredPathsPage> createState() => _MonitoredPathsPageState();
}

class _MonitoredPathsPageState extends State<MonitoredPathsPage>
    with AutomaticKeepAliveClientMixin<MonitoredPathsPage> {
  @override
  bool get wantKeepAlive => true;
  List<String> _paths = [];
  late SharedPreferences _prefs;
  bool _initialized = false;
  // ignore: prefer_final_fields
  Map<String, bool> _selected = {};
  SupaBaseHandler handler = SupaBaseHandler();
  bool _loading = false;

  @override
  void initState() {
    getPathInstance().then((SharedPreferences prefsFuture) {
      _prefs = prefsFuture;
      List<String>? nullCheckList = _prefs.getStringList('paths');
      if (nullCheckList == null) {
        _paths = [];
      } else {
        for (String element in nullCheckList) {
          _paths.add(element);
          _selected[element] = false;
        }
      }
      setState(() {});
    });
    _initialized = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_initialized) {
      return Center(
        child: Stack(children: [
          Column(
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 5)),
              Expanded(
                child: ListView.separated(
                    itemBuilder: (BuildContext context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                              value: checkSelected(_paths[index]),
                              onChanged: (value) {
                                setState(() {
                                  _selected[_paths[index]] = value!;
                                });
                              }),
                          Text(
                            _paths[index],
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                              onPressed: () {
                                removePath(
                                  _prefs,
                                  _paths[index],
                                );
                                setState(() {});
                              },
                              child: const Text(
                                '- Remove Path',
                                style: TextStyle(color: Colors.red),
                              ))
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, index) {
                      return const Divider();
                    },
                    itemCount: _paths.length),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (!kIsWeb) {
                      addPath(_prefs);
                      setState(() {});
                    }
                  },
                  child: const Text('+ Add Path')),
              const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
              checkFolder(context)
            ],
          ),
          loadingCheck()
        ]),
      );
    } else {
      return const LoadAnimation();
    }
  }

  bool? checkSelected(String curPath) {
    if (_selected[curPath] != null) {
      return _selected[curPath];
    } else {
      return false;
    }
  }

  Widget loadingCheck() {
    if (_loading) {
      return AbsorbPointer(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: const LoadAnimation(),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<SharedPreferences> getPathInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  void addPath(SharedPreferences prefs) async {
    await FilePicker.platform.getDirectoryPath().then((value) {
      if (value == null) {
        // User canceled the picker
      } else if (value.length > 4) {
        _paths.add(value.toString());
        prefs.setStringList('paths', _paths);
      }
    });
  }

  void removePath(SharedPreferences prefs, String path) {
    if (_selected[path] != null) {
      prefs.remove(path);
      _paths.remove(path);
      prefs.setStringList('paths', _paths);
    }
  }

  Widget checkFolder(BuildContext context) {
    if (_selected.containsValue(true)) {
      return ElevatedButton(
          onPressed: () => onCheckPress(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.refresh),
              Text(' Check selected folder(s) for missing files?')
            ],
          ));
    } else {
      return Container();
    }
  }

  Future<void> uploadData(List<String> dataList, BuildContext context) async {
    for (String path in dataList) {
      handler.addData(path, DateTime.now().toString(),
          DateTime.now().toString(), supabase.auth.currentUser?.email, context);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Uploaded the File(s)'),
    ));
    _selected.clear();
  }

  Future<void> onCheckPress(BuildContext context) async {
    _loading = true;
    List<String> filesParsed = [];
    for (var key in _selected.keys) {
      if (_selected[key] == true) {
        List files = io.Directory(key).listSync(recursive: true);
        for (var i in files) {
          if (i.toString().startsWith('File')) {
            String path = i.toString();
            int lastInd = path.lastIndexOf(RegExp(r'\\[^\\]+\\[^\\]+$'));
            // replace all parentheses with a tilde
            path = path.replaceAllMapped(RegExp(r"(\(|\))"), (match) => "~");
            filesParsed.add(path.substring(lastInd, path.length - 1));
          }
        }
      }
    }
    await handler.checkFiles(context, filesParsed).then((value) async {
      // if query completes and returns data
      if (value != null || value != []) {
        // the differences represent the files in the paths that aren't in the database.
        List<String> returnedFilenames = [];
        for (var element in value!) {
          returnedFilenames.add(element['filename']);
        }
        List<String> differences =
            filesParsed.where((i) => !returnedFilenames.contains(i)).toList();
        if (differences.isNotEmpty) {
          await uploadData(differences, context);
        } else if (differences.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'No new file information to upload.',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.amber,
          ));
        }
      }
    });
    _loading = false;
  }
}
