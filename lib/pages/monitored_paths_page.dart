import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scantrack/data_tables/supabase_handler.dart';
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
  final Map<String, bool> _selected = {};
  SupaBaseHandler handler = SupaBaseHandler();
  bool _loading = false;
  bool _selectAll = false;

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Select All: "),
                  Checkbox(
                      value: _selectAll,
                      onChanged: (value) => selectAll(value!)),
                ],
              ),
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
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Text(
                              _paths[index],
                              textAlign: TextAlign.center,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  removePath(
                                    _prefs,
                                    _paths[index],
                                  );
                                });
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

  void selectAll(bool isChecked) {
    _selected.updateAll((key, value) => isChecked);
    setState(() {
      _selectAll = isChecked;
    });
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
        _selected[value.toString()] = false;
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
    try {
      handler.addData(dataList, context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Uploaded the File(s)'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error adding data'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // when file check button is pressed
  Future<void> onCheckPress(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    List<String> filesParsed = []; // list of files after their names get fixed
    for (var key in _selected.keys) {
      // for each path
      if (_selected[key] == true) {
        // if path is selected
        if (io.Directory(key).existsSync()) {
          // if the path exists
          // files = all the file names in the directory
          List files = io.Directory(key).listSync(recursive: true);
          for (var i in files) {
            // for each filename
            if (i.toString().startsWith('File')) {
              // if
              String path = i.toString();
              // find the index of where to splice the string
              int lastInd = path.lastIndexOf(RegExp(
                  r"\\((d|D)esktop|(d|D)ocuments|(d|D)ownloads)\\[\S|\W]+$"));
              // replace all parentheses with a tilde
              path = path.replaceAllMapped(RegExp(r"(\(|\))"), (match) => "~");
              path = path.replaceAllMapped(
                  RegExp(r"\\((d|D)esktop|(d|D)ocuments|(d|D)ownloads)"),
                  (match) => "");
              filesParsed.add(path.substring(lastInd, path.length - 1));
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "The path, $key, does not exist on this device.",
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
    if (filesParsed.isNotEmpty) {
      await handler.checkFiles(context, filesParsed).then((value) async {
        if (value != null) {
          // returnedFilenames = all the duplicate files that don't need to go into the db
          List<String> returnedFilenames = [];
          for (var element in value) {
            returnedFilenames.add(element['filename']);
          }

          // differences = all the files that SHOULD go into the db
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
    }
    setState(() {
      _loading = false;
    });
  }
}
