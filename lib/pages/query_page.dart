import 'package:flutter/material.dart';
import 'package:scantrack/pages/query_results_page.dart';
import 'package:scantrack/data_tables/supabase_handler.dart';
import 'package:intl/intl.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({super.key});

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage>
    with AutomaticKeepAliveClientMixin<QueryPage> {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _textSearchController;
  late final TextEditingController _createdAfterController;
  late final TextEditingController _createdBeforeController;
  bool _loading = false;
  SupaBaseHandler handler = SupaBaseHandler();

  Future<void> _selectDate(
      BuildContext context, TextEditingController control) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(const Duration(days: 1)),
        firstDate: DateTime(2021),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        control.text =
            picked.toString(); // TODO: parse date into month/day/year
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
    _formKey.currentState!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Text in Filename: '),
                  ],
                ),
              ),
              SizedBox(
                height: 75,
                width: 300,
                child: TextFormField(
                  controller: _textSearchController,
                  maxLength: 255,
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Enter Text (Optional)"),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Uploaded Between: '),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                width: 300,
                child: Row(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: _createdAfterController,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: "(Optional)"),
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () =>
                            _selectDate(context, _createdAfterController),
                        child: const Icon(Icons.calendar_today)),
                    TextButton(
                        onPressed: () => setState(() {
                              _createdAfterController.clear();
                            }),
                        child: const Text("Reset Date"))
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
          const Text("AND"),
          const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
                width: 150,
              ),
              SizedBox(
                height: 50,
                width: 300,
                child: Row(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: _createdBeforeController,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: "(Optional)"),
                        ),
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
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
          ElevatedButton(
              onPressed: () => queryDb(), child: const Text("Search")),
          const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
          ElevatedButton(
              onPressed: () => setState(() {
                    _textSearchController.clear();
                    _createdAfterController.clear();
                    _createdBeforeController.clear();
                  }),
              child: const Text("Reset"))
        ],
      ),
    );
  }

  Future<void> queryDb() async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      _formKey.currentState!.setState(() {
        _loading = true;
      });

      // TEST TODO: Change to real data
      Map<String, dynamic> queryFilters = {
        'text': "test",
        "after": "1/5/2023",
        "before": "1/18/2023"
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
