import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scantrack/pages/query_results_page.dart';
import 'package:scantrack/data_tables/supabase_handler.dart';
import 'package:intl/intl.dart';
import 'package:scantrack/shared/loading_animation.dart';

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
  late final TextEditingController _createdAfterController;
  late final TextEditingController _createdBeforeController;
  bool _loading = false;
  SupaBaseHandler handler = SupaBaseHandler();
  bool isAfterError = false;
  DateFormat readableFormat = DateFormat("MM-dd-yyyy");
  bool _isValid = true;

  Future<void> _selectDate(
      BuildContext context, TextEditingController control) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(const Duration(days: 1)),
        firstDate: DateTime(2021),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        control.text = DateFormat("MM-dd-yyyy").format(picked);
      });
    }
  }

  @override
  void initState() {
    _textSearchController = TextEditingController();
    _createdAfterController = TextEditingController();
    _createdBeforeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textSearchController.dispose();
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
            children: [
              const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Text in Filename: '),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Uploaded After: '),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Uploaded Before: "),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
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
              ElevatedButton(
                  onPressed: _isValid
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _queryDb(
                                _textSearchController.text,
                                _createdAfterController.text,
                                _createdBeforeController.text);
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

  Future<void> _queryDb(String text, String after, String before) async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      _formKey.currentState!.setState(() {
        _loading = true;
      });

      Map<String, dynamic> queryFilters = {
        'text': text.isNotEmpty ? text : '',
        "after": after.isNotEmpty ? after : '',
        "before": before.isNotEmpty ? before : ''
      };

      if (mounted) {
        var results = await handler.queryDb(context, queryFilters);
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
