import 'package:bean_bot/data/menu_items.dart';
import 'package:bean_bot/model/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'debug.dart';
import 'logs.dart';
import 'mqtt/MQTTManager.dart';
import 'mqtt/state/MQTTAppState.dart';

void main() {
  runApp(MaterialApp(
    title: 'The Bean Bot',
    home: ChangeNotifierProvider<MQTTAppState>(
      create: (_) => MQTTAppState(),
      child: const BeanBot(),
    ),
  ));
}

class BeanBot extends StatefulWidget {
  const BeanBot({Key? key}) : super(key: key);

  @override
  _BeanBotState createState() => _BeanBotState();
}

class _BeanBotState extends State<BeanBot> {
  static const String _title = 'The Bean Bot';

  late MQTTAppState currentAppState;
  late MQTTManager manager;

  void _configureAndConnect() {
    currentAppState.setHostIp('192.168.0.193');
    manager = MQTTManager(
        host: currentAppState.getHostIP,
        topic: "order",
        identifier: "BeanBotDemo",
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;

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
          body: ListView(children: [
            _buildConnectionStateText(_prepareStateMessageFrom(
                currentAppState.getAppConnectionState)),
            _buildWeightInput(),
            _buildConfirmButtons(currentAppState.getAppConnectionState),
          ])),
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
          MaterialPageRoute(builder: (context) => const LogPage()),
        );
        break;
    }
  }

  final _weightForm = GlobalKey<FormState>();

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: Colors.deepOrangeAccent,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(status, textAlign: TextAlign.center),
              )),
        ),
      ],
    );
  }

  Widget _buildWeightInput() {
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
        ],
      ),
    );
  }

  Widget _buildConfirmButtons(MQTTAppConnectionState state) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                if (state == MQTTAppConnectionState.disconnected) {
                  _configureAndConnect();
                }
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
