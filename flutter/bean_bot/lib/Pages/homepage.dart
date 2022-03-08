import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bean_bot/data/menu_items.dart';
import 'package:bean_bot/model/menu_item.dart';

import 'package:bean_bot/Pages/debug.dart';
import 'package:bean_bot/Pages/logs.dart';
import 'package:bean_bot/mqtt/MQTTManager.dart';
import 'package:bean_bot/Providers/MQTTAppState.dart';
import 'package:bean_bot/Providers/weight_input_state.dart';
// TODO: clean up code
// TODO: add comments to the code
// TODO: make Provider work
// TODO: wrap AdminInput in a foldable widget
// TODO: add CurrentWeight widget

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /////////////////////////// Variables ///////////////////////////
  static const String _title = 'The Bean Bot';

  final _weightForm = GlobalKey<FormState>();
  final _adminForm = GlobalKey<FormState>();

  final TextEditingController _ipTextController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  late MQTTManager manager;
  late MQTTAppState currentAppState;

  String beanWeight = '';

  /////////////////////////// Widgets ///////////////////////////
  @override
  // Builds the main components of the home screen.
  Widget build(BuildContext context) {
    final MQTTAppState appState =
        Provider.of<MQTTAppState>(context, listen: false);
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
        body: ListView(
          children: [
            _buildConnectionStateText(
              _prepareStateMessageFrom(
                  Provider.of<MQTTAppState>(context).getAppConnectionState),
              setColor(
                  Provider.of<MQTTAppState>(context).getAppConnectionState),
            ),
            _buildWeightInput(
                Provider.of<MQTTAppState>(context).getAppConnectionState),
            _buildConfirmButtons(
                Provider.of<MQTTAppState>(context).getAppConnectionState),
            _buildAdminInput(),
          ],
        ),
      ),
      initialRoute: '/',
      routes: {
        '/debug': (context) => const DebugPage(),
        '/logs': (context) => const LogPage(),
      },
    );
  }

  // Creates the connection state widget on top of the screen.
  Widget _buildConnectionStateText(String status, Color color) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: color,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(status, textAlign: TextAlign.center),
              )),
        ),
      ],
    );
  }

  // Builds the input field for ordering beans.
  Widget _buildWeightInput(MQTTAppConnectionState state) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _weightForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the weight',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (state == MQTTAppConnectionState.disconnected) {
                  return 'Please connect to the Arduino before ordering beans.';
                }
                if (state == MQTTAppConnectionState.connected) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the weight';
                  }
                }
                return null;
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: BeanKindDropdown(),
          ),
          const Divider(
            indent: 8,
            endIndent: 8,
          )
        ],
      ),
    );
  }

  // Builds the confirm buttons the ordering beans.
  Widget _buildConfirmButtons(MQTTAppConnectionState state) {
    return Row(
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
                  Provider.of<WeightInputState>(context, listen: false)
                      .setWeight(_weightController.text);
                  beanWeight =
                      Provider.of<WeightInputState>(context, listen: false)
                          .getWeight;
                  _showConfirmMessage(
                      Provider.of<MQTTAppState>(context, listen: false)
                          .getAppConnectionState);
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

  // Builds the widget to enter the IP address.
  Widget _buildAdminInput() {
    final MQTTAppState appState =
    Provider.of<MQTTAppState>(context, listen: false);
    // Keep a reference to the app state.
    currentAppState = appState;
    return Form(
      key: _adminForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 4),
                child: Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'MQTT IP',
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                    ),
                    keyboardType: TextInputType.phone,
                    controller: _ipTextController,
                    maxLength: 13,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the IP address';
                      }
                      // Checks if a valid IP address is entered.
                      // TODO: add valid IP address validation: https://www.geeksforgeeks.org/program-to-validate-an-ip-address/
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_adminForm.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                        if (currentAppState.getAppConnectionState ==
                            MQTTAppConnectionState.disconnected) {
                          currentAppState.setHostIp(_ipTextController.text);
                          _configureAndConnect();
                        }
                        Provider.of<MQTTAppState>(context, listen: false)
                            .setHostIp(_ipTextController.text);
                        if (currentAppState.getAppConnectionState ==
                            MQTTAppConnectionState.connected) {
                          Provider.of<MQTTAppState>(context, listen: false)
                              .setAppConnectionState(
                              MQTTAppConnectionState.connected);
                        }
                      }
                    },
                    child: const Text('Connect'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      primary: Colors.white,
                      onSurface: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: ElevatedButton(
                    onPressed: () {
                      // currentAppState.setHostIp(_ipTextController.text);
                      if (currentAppState.getAppConnectionState ==
                          MQTTAppConnectionState.connected) {
                        _disconnect();
                      }
                      if (currentAppState.getAppConnectionState ==
                          MQTTAppConnectionState.disconnected) {
                        Provider.of<MQTTAppState>(context, listen: false)
                            .setAppConnectionState(
                            MQTTAppConnectionState.disconnected);
                        Provider.of<MQTTAppState>(context, listen: false)
                            .setHostIp(_ipTextController.text);
                      }
                    },
                    child: const Text('Disconnect'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.red,
                      onSurface: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            indent: 8,
            endIndent: 8,
          ),
        ],
      ),
    );
  }

  // Gets the connection state and returns the associated string.
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

  // Gets the connection state and returns the associated color.
  Color setColor(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return Colors.green;
      case MQTTAppConnectionState.connecting:
        return Colors.deepOrange;
      case MQTTAppConnectionState.disconnected:
        return Colors.red;
    }
  }

  // Creates the navigation menu.
  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem(
        value: item,
        child: Text(item.text),
      );


  /////////////////////////// Voids ///////////////////////////
  @override
  void initState() {
    super.initState();
  }

  // Sends a message over the MQTT connection.
  void _publishMessage(String text) {
    manager.publish(text);
    _weightController.clear();
  }

  @override
  // Clears the text of the IP controller.
  void dispose() {
    _ipTextController.dispose();
    super.dispose();
  }

  // Connects the app to the broker.
  void _configureAndConnect() {
    final MQTTAppState appState =
        Provider.of<MQTTAppState>(context, listen: false);
    // Keep a reference to the app state.
    currentAppState = appState;
    manager = MQTTManager(
        host: currentAppState.getHostIP,
        topic: "order",
        identifier: "BeanBotDemo",
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  // Disconnects the app from the broker.
  void _disconnect() {
    manager.disconnect();
  }

  // Handles the navigation of the popupmenu.
  void onSelected(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.itemDebug:
        Navigator.pushNamed(context, '/debug');
        break;
      case MenuItems.itemLog:
        Navigator.pushNamed(context, '/logs');
        break;
    }
  }

  // Opens a dialog box when the user wants to order beans.
  void _showConfirmMessage(MQTTAppConnectionState state) {
    String beanColor =
        Provider.of<WeightInputState>(context, listen: false).getColor;

    showDialog(
      context: context, barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    "You're about to order $beanWeight g of $beanColor beans. Are you sure? Click OK to continue. Press Cancel to cancel to order."),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                if (state == MQTTAppConnectionState.connected) {
                  String beanColor = Provider.of<WeightInputState>(context, listen: false).getColor;
                  String beanWeight = Provider.of<WeightInputState>(context, listen: false).getColor;
                  String beanWeightIndex = '0';

                  switch (beanWeight) {
                    case 'Green beans':
                       beanWeightIndex = '0';
                       break;
                    case 'White beans':
                      beanWeightIndex = '1';
                      break;
                    case 'Red beans':
                      beanWeightIndex = '1';
                      break;
                  }
                  String message = beanWeightIndex + beanColor;
                  _publishMessage(message);
                }
                Navigator.of(context).pop();
                _showOrderMessage();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Opens a dialog box when the user has ordered beans.
  void _showOrderMessage() {
    String beanColor = Provider.of<WeightInputState>(context, listen: false).getColor;
    showDialog(
      context: context, barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bean Order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    "You've ordered $beanWeight g of $beanColor."),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class BeanKindDropdown extends StatefulWidget {
  const BeanKindDropdown({Key? key}) : super(key: key);

  @override
  _BeanKindDropdownState createState() => _BeanKindDropdownState();
}

class _BeanKindDropdownState extends State<BeanKindDropdown> {
  String beanColor = 'Green beans';
  @override
  // Builds the radio buttons for selection the color of the beans. 
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: -10, vertical: 5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      child: Column(
        children: [
          Padding(
            child: ListTile(
              title: const Text("Green beans"),
              leading: Radio(
                  value: "Green beans",
                  groupValue: beanColor,
                  onChanged: (value) {
                    setState(() {
                      beanColor = value.toString();
                      Provider.of<WeightInputState>(context, listen: false).setColor(beanColor);
                    });
                  }),
            ),
            padding: const EdgeInsets.all(0.0),
          ),
          Padding(
            child: ListTile(
              title: const Text("White beans"),
              leading: Radio(
                  value: "White beans",
                  groupValue: beanColor,
                  onChanged: (value) {
                    setState(() {
                      beanColor = value.toString();
                      Provider.of<WeightInputState>(context, listen: false).setColor(beanColor);
                    });
                  }),
            ),
            padding: const EdgeInsets.all(0.0),
          ),
          Padding(
            child: ListTile(
              title: const Text("Red beans"),
              leading: Radio(
                  value: "Red beans",
                  groupValue: beanColor,
                  onChanged: (value) {
                    setState(() {
                      beanColor = value.toString();
                      Provider.of<WeightInputState>(context, listen: false).setColor(beanColor);
                    });
                  }),
            ),
            padding: const EdgeInsets.all(0.0),
          ),
        ],
      ),
    );
  }
}

/*
class ConnectionPageView extends StatefulWidget {
  const ConnectionPageView({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ConnectionPageViewState();
  }
}

class _ConnectionPageViewState extends State<ConnectionPageView> {





  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Page'),
      ),
      body: ListView(children: [
        _buildConnectionStateText(
          _prepareStateMessageFrom(Provider
              .of<MQTTAppState>(context, listen: false)
              .getAppConnectionState),
          setColor(Provider
              .of<MQTTAppState>(context, listen: false)
              .getAppConnectionState),),
        _buildAdminInput()
      ]),
    );
  }

  Widget _buildConnectionStateText(String status, Color color) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: color,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(status, textAlign: TextAlign.center),
              )),
        ),
      ],
    );
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

  Color setColor(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return Colors.green;
      case MQTTAppConnectionState.connecting:
        return Colors.deepOrange;
      case MQTTAppConnectionState.disconnected:
        return Colors.red;
    }
  }

  Widget _buildAdminInput() {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    return Form(
      key: _adminForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 4),
                child: Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'MQTT IP',
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                    ),
                    keyboardType: TextInputType.phone,
                    controller: _ipTextController,
                    maxLength: 13,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the IP address';
                      }
                      // Checks if a valid IP address is entered.
                      if (value.length != 13) {
                        return 'Please enter a valid IP address';
                      }
                      if (value.length == 13) {
                        if (value[3] != '.' ||
                            value[7] != '.' ||
                            value[9] != '.') {
                          return 'Please enter a valid IP address';
                        }
                      }

                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_adminForm.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                        if (currentAppState.getAppConnectionState ==
                            MQTTAppConnectionState.disconnected) {
                          currentAppState.setHostIp(_ipTextController.text);
                          _configureAndConnect();
                        }
                        Provider.of<MQTTAppState>(context, listen: false)
                            .setAppConnectionState(
                            MQTTAppConnectionState.connected);
                        Provider.of<MQTTAppState>(context, listen: false)
                            .setHostIp(_ipTextController.text);
                      }
                      print(Provider
                          .of<MQTTAppState>(context, listen: false)
                          .getAppConnectionState);
                    },
                    child: const Text('Connect'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      primary: Colors.white,
                      onSurface: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: ElevatedButton(
                    onPressed: () {
                      // currentAppState.setHostIp(_ipTextController.text);
                      if (currentAppState.getAppConnectionState ==
                          MQTTAppConnectionState.connected) {
                        _disconnect();
                      }
                      Provider.of<MQTTAppState>(context, listen: false)
                          .setAppConnectionState(
                          MQTTAppConnectionState.disconnected);
                      print(Provider
                          .of<MQTTAppState>(context, listen: false)
                          .getAppConnectionState);
                    },
                    child: const Text('Disconnect'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.red,
                      onSurface: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            indent: 8,
            endIndent: 8,
          ),
        ],
      ),
    );
  }

  void initState() {
    MQTTAppConnectionState currentAppState = MQTTAppConnectionState
        .disconnected;
  }

  void dispose() {
    _ipTextController.dispose();
    super.dispose();
  }

  void _configureAndConnect() {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    manager = MQTTManager(
        host: currentAppState.getHostIP,
        topic: "order",
        identifier: "BeanBotDemo",
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
  }
}*/
