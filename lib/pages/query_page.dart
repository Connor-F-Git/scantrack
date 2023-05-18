import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scantrack/pages/query_results_page.dart';
import 'package:scantrack/data_tables/supabase_handler.dart';
import 'package:intl/intl.dart';
import 'package:scantrack/shared/loading_animation.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({super.key});

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage>
    with AutomaticKeepAliveClientMixin<QueryPage> {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _textSearchController;
  late final TextEditingController _uploaderController;
  late final TextEditingController _createdAfterController;
  late final TextEditingController _createdBeforeController;
  final TextEditingController searchController = TextEditingController();
  String dropdownMenuLabel = "All";

  bool _loading = false;
  SupaBaseHandler handler = SupaBaseHandler();
  bool isAfterError = false;
  DateFormat readableFormat = DateFormat("MM-dd-yyyy");
  bool _isValid = true;
  bool _uploaderLoading = false;
  int _radioValue = 0;
  Map<int, UploaderListItem> uploaderMap = {};

  Future<void> _selectDate(
      BuildContext context, TextEditingController control) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        control.text = DateFormat("MM-dd-yyyy").format(picked);
      });
    }
  }

  Future<void> _getUploaderList() async {
    setState(() {
      _uploaderLoading = true;
    });
    dynamic emailReturn = await handler.getEmails(context);

    for (int index = 0; index < emailReturn.length; index++) {
      String val = emailReturn[index]['uploader'].toString();
      uploaderMap[index] = UploaderListItem(val, true);
    }
    setState(() {
      _uploaderLoading = false;
    });
  }

  Widget _uploaderLoadCheck() {
    if (_uploaderLoading) {
      return const Text("Loading...");
    } else {
      return SizedBox(
        width: 243,
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            focusNode: FocusNode(canRequestFocus: false),
            dropdownSearchData: DropdownSearchData(
              searchController: searchController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  controller: searchController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: 'Search for a user...',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            onChanged: (value) {},
            hint: Text("Number of Users Selected: $dropdownMenuLabel"),
            items: uploaderMap.entries.map((item) {
              String itemName = item.value.name;
              return DropdownMenuItem<String>(
                value: itemName,
                //disable default onTap to avoid closing menu when selecting an item
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, menuSetState) {
                    return InkWell(
                      onTap: () {
                        //This rebuilds the StatefulWidget to update the button's text
                        setState(() {
                          uploaderMap[item.key]!.isSelected =
                              !item.value.isSelected;
                          dropdownMenuLabel = uploaderMap.values
                              .where((element) => element.isSelected)
                              .length
                              .toString();
                          _uploaderController.text =
                              "Number of Users Selected: $dropdownMenuLabel";
                        });
                        //This rebuilds the dropdownMenu Widget to update the check mark
                        menuSetState(() {});
                      },
                      child: SizedBox(
                        width: 243,
                        child: Row(
                          children: [
                            item.value.isSelected
                                ? const Icon(Icons.check_box_outlined)
                                : const Icon(Icons.check_box_outline_blank),
                            Expanded(
                              child: Text(
                                itemName,
                                textWidthBasis: TextWidthBasis.parent,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    _getUploaderList();
    _textSearchController = TextEditingController();
    _uploaderController = TextEditingController();
    _createdAfterController = TextEditingController();
    _createdBeforeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    _textSearchController.dispose();
    _uploaderController.dispose();
    _createdAfterController.dispose();
    _createdBeforeController.dispose();
    super.dispose();
  }

  void checkValid() {
    if (_formKey.currentState!.validate()) {
      _isValid = true;
    } else {
      _isValid = false;
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Form(
          onChanged: () => checkValid(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(child: Text('Uploader:')),
                  SizedBox(height: 40, width: 300, child: _uploaderLoadCheck()),
                  TextButton(
                      onPressed: () {
                        uploaderMap.forEach((key, value) {
                          setState(() {
                            value.isSelected = true;
                            dropdownMenuLabel = uploaderMap.values
                                .where((element) => element.isSelected)
                                .length
                                .toString();
                            _uploaderController.text =
                                "Number of Users Selected: $dropdownMenuLabel";
                          });
                        });
                      },
                      child: const Text("Select All")),
                  TextButton(
                      onPressed: () {
                        uploaderMap.forEach((key, value) {
                          setState(() {
                            value.isSelected = false;
                            dropdownMenuLabel = uploaderMap.values
                                .where((value) => value.isSelected)
                                .length
                                .toString();
                            _uploaderController.text =
                                "Number of Users Selected: $dropdownMenuLabel";
                          });
                        });
                      },
                      child: const Text("Deselect All"))
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Text in Filename:'),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.33,
                    child: TextFormField(
                      controller: _textSearchController,
                      maxLength: 256,
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Enter Text (Optional)"),
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Uploaded After:'),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.28,
                      child: TextFormField(
                        readOnly: true,
                        validator: (value) {
                          // Validator makes sure the first date is before the second
                          if ((_createdAfterController.text.isNotEmpty &&
                                  _createdBeforeController.text.isNotEmpty) &&
                              (formatStringToDate(_createdAfterController.text)
                                  .isAfter(formatStringToDate(
                                      _createdBeforeController.text)))) {
                            return "After needs to come earlier than before";
                          } else {
                            return null;
                          }
                        },
                        textAlign: TextAlign.center,
                        controller: _createdAfterController,
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: "Date (Optional)",
                            errorMaxLines: 2),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          _selectDate(context, _createdAfterController);
                        },
                        child: const Icon(Icons.calendar_today)),
                    TextButton(
                        onPressed: () => setState(() {
                              _createdAfterController.clear();
                            }),
                        child: const Text("Reset Date")),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Uploaded Before: "),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.28,
                    child: TextFormField(
                      readOnly: true,
                      textAlign: TextAlign.center,
                      controller: _createdBeforeController,
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Date (Optional)"),
                    ),
                  ),
                  TextButton(
                      onPressed: () =>
                          _selectDate(context, _createdBeforeController),
                      child: const Icon(Icons.calendar_today)),
                  TextButton(
                      onPressed: () => setState(() {
                            _createdBeforeController.clear();
                          }),
                      child: const Text("Reset Date"))
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.0,
                      width: 200.0,
                      child: RadioListTile(
                          title: const Text("File Search"),
                          value: 0,
                          groupValue: _radioValue,
                          onChanged: (value) {
                            setState(() {
                              _radioValue = value!;
                            });
                          }),
                    ),
                    SizedBox(
                      height: 50.0,
                      width: 200.0,
                      child: RadioListTile(
                          title: const Text("File Count"),
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: (value) {
                            setState(() {
                              _radioValue = value!;
                            });
                          }),
                    ),
                  ]),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
              ElevatedButton(
                  onPressed: _isValid
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _queryDb(
                                _textSearchController.text,
                                _createdAfterController.text,
                                _createdBeforeController.text,
                                _uploaderController.text);
                          }
                        }
                      : null,
                  child: const Text("Search")),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
              ElevatedButton(
                  onPressed: () => setState(() {
                        _textSearchController.clear();
                        _createdAfterController.clear();
                        _createdBeforeController.clear();
                        uploaderMap.forEach(
                          (key, value) {
                            setState(() {
                              value.isSelected = true;
                            });
                          },
                        );
                        uploaderMap.forEach((key, _) {
                          dropdownMenuLabel = uploaderMap.values
                              .where((value) => value.isSelected)
                              .length
                              .toString();
                          _uploaderController.text =
                              "Number of Users Selected: $dropdownMenuLabel";
                        });
                      }),
                  child: const Text("Reset")),
            ],
          ),
        ),
        loadingCheck(),
      ],
    );
  }

  DateTime formatStringToDate(String input) {
    return readableFormat.parse(input);
  }

  Widget returnAfterError() {
    if (isAfterError) {
      return const Text(
        "'After' date needs to be earlier than 'Before'",
        style: TextStyle(color: Colors.red),
      );
    } else {
      return Container();
    }
  }

  Future<void> _queryDb(
      String text, String after, String before, String uploader) async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      _formKey.currentState!.setState(() {
        _loading = true;
      });

      List<String> selectedUploaders = [];

      uploaderMap.forEach((key, value) {
        if (value.isSelected) {
          selectedUploaders.add(value.name);
        }
      });

      Map<String, dynamic> queryFilters = {
        'uploaders': selectedUploaders.isNotEmpty
            ? selectedUploaders
                .toString()
                .replaceFirst('[', '{')
                .replaceFirstMapped(RegExp(r'\]'), (match) => '}',
                    selectedUploaders.toString().lastIndexOf(']'))
            : '{}',
        'text': text.isNotEmpty ? text : '',
        "after": after.isNotEmpty ? after : '',
        "before": before.isNotEmpty ? before : ''
      };

      if (mounted) {
        List<dynamic>? results;
        if (_radioValue == 0) {
          results = await handler.queryDb(context, queryFilters);
        } else if (_radioValue == 1) {
          results = await handler.queryDbFileCount(context, queryFilters);
        }

        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QueryResults(
                        queryInfo: results,
                      )));
        }
      }

      setState(() {
        _loading = false;
      });
    }
  }
}

class UploaderListItem {
  String name;

  bool isSelected;

  UploaderListItem(this.name, this.isSelected);
}
