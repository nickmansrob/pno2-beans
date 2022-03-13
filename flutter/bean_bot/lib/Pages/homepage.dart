import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bean_bot/data/menu_items.dart';
import 'package:bean_bot/model/menu_item.dart';

import 'package:bean_bot/Pages/debug.dart';
import 'package:bean_bot/Pages/logs.dart';
import 'package:bean_bot/mqtt/MQTTManager.dart';
import 'package:bean_bot/Providers/MQTTAppState.dart';
import 'package:bean_bot/Providers/OrderState.dart';
import 'package:expansion_widget/expansion_widget.dart';

import 'dart:math' as math;

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
  late OrderState currentOrderState;

  double weightFraction = 0;

  String logTopic = 'logListener';
  String weightTopic = 'weightListener';

  /////////////////////////// Widgets ///////////////////////////
  @override
  // Builds the main components of the home screen.
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    final OrderState orderState = Provider.of<OrderState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    currentOrderState = orderState;
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
              _prepareStateMessageFrom(appState.getAppConnectionState),
              setColor(appState.getAppConnectionState),
            ),
            _buildWeightInput(appState.getAppConnectionState),
            _buildConfirmButtons(appState.getAppConnectionState),
            _buildDivider(),
            _buildShowCurrentWeight(
                appState.getWeightText, appState.getAppConnectionState),
            _buildDivider(),
            _buildShowCurrentOrder(
                orderState.getCurrentOrder, appState.getAppConnectionState),
            _buildDivider(),
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
    return Container(
      child: Form(
        key: _weightForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, top: 12, right: 8, bottom: 2),
              child: Text(
                'Order Beans',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TextFormField(
                enabled: disableTextField(state),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _buildBeanColorSelector(context, state),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the color selection widget.
  Widget _buildBeanColorSelector(
      BuildContext context, MQTTAppConnectionState state) {
    return Container(
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: -10, vertical: 5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        child: Column(
          children: [
            Padding(
              child: ListTile(
                title: const Text("Silo 1"),
                leading: Radio(
                  value: "Silo 1",
                  groupValue: currentOrderState.getSiloNumber,
                  onChanged: disableTextField(state)
                      ? (value) {
                          setState(() {
                            currentOrderState.setSiloNumber(value.toString());
                            Provider.of<OrderState>(context, listen: false)
                                .setSiloNumber(currentOrderState.getSiloNumber);
                          });
                        }
                      : null,
                ),
              ),
              padding: const EdgeInsets.all(0.0),
            ),
            Padding(
              child: ListTile(
                title: const Text("Silo 2"),
                leading: Radio(
                  value: "Silo 2",
                  groupValue: currentOrderState.getSiloNumber,
                  onChanged: disableTextField(state)
                      ? (value) {
                          setState(() {
                            currentOrderState.setSiloNumber(value.toString());
                            Provider.of<OrderState>(context, listen: false)
                                .setSiloNumber(currentOrderState.getSiloNumber);
                          });
                        }
                      : null,
                ),
              ),
              padding: const EdgeInsets.all(0.0),
            ),
            Padding(
              child: ListTile(
                title: const Text("Silo 3"),
                leading: Radio(
                  value: "Silo 3",
                  groupValue: currentOrderState.getSiloNumber,
                  onChanged: disableTextField(state)
                      ? (value) {
                          setState(() {
                            currentOrderState.setSiloNumber(value.toString());
                            Provider.of<OrderState>(context, listen: false)
                                .setSiloNumber(currentOrderState.getSiloNumber);
                          });
                        }
                      : null,
                ),
              ),
              padding: const EdgeInsets.all(0.0),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the confirm buttons the ordering beans.
  Widget _buildConfirmButtons(MQTTAppConnectionState state) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: disableTextField(state)
                    ? () {
                        // Dismisses keyboard
                        if (!disableTextField(state)) {
                          null;
                        } else {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_weightForm.currentState!.validate()) {
                            currentOrderState
                                .setWeightOrder(_weightController.text);
                            _showConfirmMessage(
                                currentAppState.getAppConnectionState);
                          }
                        }
                      }
                    : null,
                child: const Text('Submit'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: disableTextField(state)
                    ? () {
                        _weightController.clear();
                        currentOrderState.setSiloNumber('');
                      }
                    : null,
                child: const Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      indent: 8,
      endIndent: 8,
    );
  }

  // Builds a widget which displays the current weight of the beans.
  Widget _buildShowCurrentWeight(String text, MQTTAppConnectionState state) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Row(
              children: const [
                Text(
                  'Current weigth',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: InputDecorator(
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Row(children: [Text('${text}g')]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a widget which displays the current bean order.
  Widget _buildShowCurrentOrder(String text, MQTTAppConnectionState state) {
    double width = MediaQuery.of(context).size.width;

    if (double.tryParse(currentOrderState.getWeightOrder) != null) {
      weightFraction = double.parse(currentAppState.getWeightText) /
          double.parse(currentOrderState.getWeightOrder);
    }

    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Row(
              children: const [
                Text(
                  'Current Order',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Positioned(
                left: 9,
                top: 5,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(4.0)),
                  width: weightFraction * (width - 18),
                  height: 46,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: Row(children: [
                      Text(
                          'Your current order is: ${currentOrderState.getCurrentOrder} (${(weightFraction*100).toStringAsFixed(1)}%).')
                    ]),
                  ),
                ),
              ),
            ],
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

  // Function to disable textfields when not connected to the Arduino.
  bool disableTextField(MQTTAppConnectionState state) {
    if (state == MQTTAppConnectionState.disconnected ||
        state == MQTTAppConnectionState.connecting) {
      return false;
    } else {
      return true;
    }
  }

  // Creates the navigation menu.
  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem(
        value: item,
        child: Text(item.text),
      );

  // Builds the widget to enter the IP address.
  Widget _buildAdminInput() {
    final MQTTAppState appState =
        Provider.of<MQTTAppState>(context, listen: false);
    // Keep a reference to the app state.
    currentAppState = appState;
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 8),
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        child: ExpansionWidget(
          initiallyExpanded: false,
          titleBuilder:
              (double animationValue, _, bool isExpanded, toggleFunction) {
            return InkWell(
                onTap: () => toggleFunction(animated: true),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Text(
                          'Connect to broker',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: math.pi * animationValue / 2,
                        child: const Icon(Icons.arrow_right, size: 40),
                        alignment: Alignment.center,
                      )
                    ],
                  ),
                ));
          },
          content: Form(
            key: _adminForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Broker IP-address',
                            isDense: true,
                            contentPadding: EdgeInsets.all(10),
                          ),
                          keyboardType: TextInputType.phone,
                          controller: _ipTextController,
                          maxLength: 13,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the IP address';
                            } else {
                              // Checks if a valid IP address is entered.
                              if (validateIp(value) == false) {
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_adminForm.currentState!.validate()) {
                              if (currentAppState.getAppConnectionState ==
                                  MQTTAppConnectionState.disconnected) {
                                currentAppState
                                    .setHostIp(_ipTextController.text);
                                _configureAndConnect();
                              }
                              Provider.of<MQTTAppState>(context, listen: false)
                                  .setHostIp(_ipTextController.text);
                              if (currentAppState.getAppConnectionState ==
                                  MQTTAppConnectionState.connected) {
                                Provider.of<MQTTAppState>(context,
                                        listen: false)
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /////////////////////////// Voids and functions ///////////////////////////
  @override
  void initState() {
    super.initState();
  }

  // Sends a message over the MQTT connection.
  void _publishMessage(String text, String topic) {
    manager.publish(text, topic);
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
    final OrderState orderState =
        Provider.of<OrderState>(context, listen: false);

    // Keep a reference to the app state and order.
    currentAppState = appState;

    manager = MQTTManager(
        host: currentAppState.getHostIP,
        topic1: "order",
        topic2: "logListener",
        topic3: "weightListener",
        identifier: "FlutterBeanBot",
        state: currentAppState,
        orderState: currentOrderState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  // Disconnects the app from the broker.
  void _disconnect() {
    manager.disconnect();
    currentAppState.setReceivedWeightText('0');
    currentOrderState.setCurrentOrder('no order');
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
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    "You're about to order ${currentOrderState.getWeightOrder}g of ${currentOrderState.getSiloNumber.toLowerCase()}. Are you sure? Click OK to continue. Press Cancel to cancel the order."),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (state == MQTTAppConnectionState.connected) {
                  String beanWeightIndex = '0';
                  switch (currentOrderState.getSiloNumber) {
                    case 'Silo 1':
                      beanWeightIndex = '0';
                      break;
                    case 'Silo 2':
                      beanWeightIndex = '1';
                      break;
                    case 'Silo 3':
                      beanWeightIndex = '2';
                      break;
                  }
                  String message =
                      beanWeightIndex + currentOrderState.getWeightOrder;
                  String currentOrder =
                      '${currentOrderState.getWeightOrder} g of ${currentOrderState.getSiloNumber.toLowerCase()}';
                  currentOrderState.setCurrentOrder(currentOrder);
                  _publishMessage(message, "order");
                  _showOrderMessage();
                }
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
    showDialog(
      context: context, barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bean Order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    "You've ordered ${currentOrderState.getWeightOrder}g of ${currentOrderState.getSiloNumber.toLowerCase()}."),
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

  void _showErrorMessage() {
    builder:
    (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const [
              Text("Something went wrong, please try again."),
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
    };
  }

  // Checks if a given string is a valid IPv4 address.
  bool validateIp(String s) {
    var chunks = s.split('.');
    int n = chunks.length;
    int intCounter = 0;
    int lengthCounter = 0;
    int periodCounter = 0;

    List containsPeriodOutput = containsPeriod(s);

    while (containsPeriodOutput[0]) {
      containsPeriodOutput = containsPeriod(containsPeriodOutput[1]);
      periodCounter++;
    }

    for (int i = 0; i < n; i++) {
      if (int.tryParse(chunks[i]) == null) {
        intCounter++;
      }
      if (int.tryParse(chunks[i]) != null) {
        if (int.parse(chunks[i]) > 255 || int.parse(chunks[i]) < 0) {
          lengthCounter++;
        }
      }
    }

    if (intCounter == 0 && lengthCounter == 0 && n == 4 && periodCounter == 3) {
      return true;
    } else {
      return false;
    }
  }

  // Checks if a given string contains a period and returns the string without that period.
  List containsPeriod(String s) {
    bool containsPeriod = s.contains('.');
    List output = [containsPeriod];

    if (containsPeriod) {
      int firstPeriodIndex = s.indexOf('.');
      String newString =
          s.substring(0, firstPeriodIndex) + s.substring(firstPeriodIndex + 1);
      output.add(newString);
      return output;
    } else {
      return output;
    }
  }
}
