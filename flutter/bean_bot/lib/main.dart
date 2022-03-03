import 'package:bean_bot/data/menu_items.dart';
import 'package:bean_bot/model/menu_item.dart';
import 'package:flutter/material.dart';

import 'debug.dart';
import 'logs.dart';

void main() {
  runApp(const MaterialApp(
    title: 'The Bean Bot',
    home: BeanBot(),
  ));
}

class BeanBot extends StatelessWidget {
  const BeanBot({Key? key}) : super(key: key);

  static const String _title = 'The Bean Bot';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
          appBar: AppBar(
            title: const Text(_title),
            actions: <Widget>[
              PopupMenuButton<MenuItem>(
                onSelected: (item) => onSelected(context, item),
                itemBuilder: (context) =>
                    [...MenuItems.items.map(buildItem).toList()],
              ),
            ],
          ),
          body: ListView(children: const [WeightInput(), ShowWeigth()])),
    );
  }

  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem(
        value: item,
        child: Text(item.text),
      );
  void onSelected(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.itemDebug:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DebugPage()),
        );
        break;
      case MenuItems.itemLog:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => LogPage()),
        );
        break;
    }
  }
}

class WeightInput extends StatefulWidget {
  const WeightInput({Key? key}) : super(key: key);

  @override
  _WeightInputState createState() => _WeightInputState();
}

class _WeightInputState extends State<WeightInput> {
  final _weightForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _weightForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the weight',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the weight';
                }
                return null;
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: BeanKindDropdown(),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Dismisses keyboard
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_weightForm.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                      }
                    },
                    child: const Text('SUBMIT'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Respond to button press
                    },
                    child: const Text('CANCEL'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BeanKindDropdown extends StatefulWidget {
  const BeanKindDropdown({Key? key}) : super(key: key);

  @override
  _BeanKindDropdownState createState() => _BeanKindDropdownState();
}

class _BeanKindDropdownState extends State<BeanKindDropdown> {
  String dropdownValue = 'Red beans';

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
            });
          },
          items: <String>['Red beans', 'Green beans', 'Brown beans']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ShowWeigth extends StatelessWidget {
  const ShowWeigth({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          indent: 8,
          endIndent: 8,
        ),
        Container(
          child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Current weigth',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )
              ]),
          margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 40),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
