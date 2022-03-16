import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  double firstWeightFraction = 0;
  double secondWeightFraction = 0;

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
            if (currentOrderState.getFirstOrder != '') _buildDivider(),
            if (currentOrderState.getFirstOrder != '' ||
                currentOrderState.getSecondOrder != '')
              _buildOrderText(),
            if (currentOrderState.getFirstOrder != '')
              _buildFirstOrder(currentAppState, currentOrderState),
            if (currentOrderState.getSecondOrder != '')
              _buildSecondOrder(currentAppState, currentOrderState),
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
              title: const Text("Silo 1"),
              leading: Radio(
                value: "Silo 1",
                groupValue: currentOrderState.getSiloNumber,
                onChanged: disableTextField(state)
                    ? (value) {
                        setState(() {
                          currentOrderState.setSiloNumber(value.toString());
                          currentOrderState
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
                          currentOrderState
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
                          currentOrderState
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
    );
  }

  // Builds the confirm buttons the ordering beans.
  Widget _buildConfirmButtons(MQTTAppConnectionState state) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
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
                              .setBothWeightOrder(_weightController.text);
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
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
    );
  }

  // Builds a divider.
  Widget _buildDivider() {
    return const Divider(
      indent: 8,
      endIndent: 8,
    );
  }

  // Builds a widget which displays the current weight of the beans.
  Widget _buildShowCurrentWeight(String text, MQTTAppConnectionState state) {
    return Column(
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
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: Row(children: [Text('${text}g')]),
            ),
          ),
        ),
      ],
    );
  }

  // Builds the widget to enter the IP address.
  Widget _buildAdminInput() {
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
                              currentAppState.setHostIp(_ipTextController.text);
                              if (currentAppState.getAppConnectionState ==
                                  MQTTAppConnectionState.connected) {
                                currentAppState.setAppConnectionState(
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
                              currentAppState.setAppConnectionState(
                                  MQTTAppConnectionState.disconnected);
                              currentAppState.setHostIp(_ipTextController.text);
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

  // Builds ordertext
  Widget _buildOrderText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                'Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Builds a widget which displays the current order.
  Widget _buildFirstOrder(MQTTAppState appState, OrderState orderState) {
    double width = MediaQuery.of(context).size.width;
    if (double.tryParse(currentOrderState.getFirstWeightOrder) != null &&
        double.parse(currentOrderState.getFirstWeightOrder) == 0) {
      firstWeightFraction = 0.0;
    } else if (double.tryParse(currentOrderState.getFirstWeightOrder) != null &&
        double.parse(currentAppState.getFirstOrderWeightText) != 0.0) {
      firstWeightFraction =
          double.parse(currentAppState.getFirstOrderWeightText) /
              double.parse(currentOrderState.getFirstWeightOrder);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 0),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Order 1 (${orderState.getFirstOrder}):',
                        style: const TextStyle(
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
              ),
            );
          },
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          child: Text(
                    'Your current order is: ${orderState.getFirstOrder}.', style: const TextStyle(fontSize: 15)),
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                        )

                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                          child: Text('Color: ${currentAppState.getFirstColor}.', style: const TextStyle(fontSize: 15)),

                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            'Current weight: ${currentAppState.getFirstOrderWeightText}g', style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 8),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Positioned(
                                    left: 1,
                                    top: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(4.0)),
                                      width: firstWeightFraction * (width - 32),
                                      height: 28,
                                    ),
                                  ),
                                   Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.black,
                                          )),
                                      width: width -32,
                                      height: 30,
                                      child: Center(
                                        child: Text(
                                          'progress (${(firstWeightFraction * 100).toStringAsFixed(1)}%)',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: ElevatedButton(
                              onPressed: disableFirstCancelOrder(appState)
                                  ? () {
                                      orderState.setFirstOrder('');
                                      firstWeightFraction = 0.0;
                                    }
                                  : null,
                              child: const Text('Cancel order'),
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                backgroundColor:
                                    colorFirstOrderCancelButton(appState),
                                onSurface:
                                    colorFirstOrderCancelButton(appState),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondOrder(MQTTAppState appState, OrderState orderState) {
    final int orderNumber;

    double width = MediaQuery.of(context).size.width;

    if (double.tryParse(currentOrderState.getSecondWeightOrder) != null &&
        double.parse(currentOrderState.getSecondWeightOrder) > 0.0) {
      secondWeightFraction =
          double.parse(currentAppState.getSecondOrderWeightText) /
              double.parse(currentOrderState.getSecondWeightOrder);
    }

    if (currentOrderState.getFirstOrder == '' &&
        currentOrderState.getSecondOrder != '') {
      orderNumber = 1;
    } else {
      orderNumber = 2;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Order $orderNumber (${orderState.getSecondOrder}):',
                          style: const TextStyle(
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
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 2),
                          child: Row(children: [
                            Text(
                                'Your current order is: ${orderState.getSecondOrder}.', style: const TextStyle(fontSize: 15))
                          ]),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 2),
                            child: Text(
                                'Color: ${currentAppState.getSecondColor}.', style: const TextStyle(fontSize: 15))),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 2),
                            child: Text(
                                'Current weight: ${currentAppState.getSecondOrderWeightText}g', style: const TextStyle(fontSize: 15))),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 8),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Positioned(
                                    left: 1,
                                    top: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(4.0)),
                                      width:
                                          secondWeightFraction * (width - 32),
                                      height: 23,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.black,
                                        )),
                                    width: width - 32,
                                    height: 25,
                                    child: Center(
                                      child: Text(
                                        'progress (${(secondWeightFraction * 100).toStringAsFixed(1)}%)',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.black,
                                          fontSize: 11,

                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: ElevatedButton(
                              onPressed: disableSecondCancelOrder(appState)
                                  ? () {
                                      orderState.setSecondOrder('');
                                      secondWeightFraction = 0.0;
                                    }
                                  : null,
                              child: const Text('Cancel order'),
                              style: TextButton.styleFrom(
                                primary: Colors.white,
                                backgroundColor:
                                    colorSecondOrderCancelButton(appState),
                                onSurface:
                                    colorSecondOrderCancelButton(appState),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ////////////////////////// Helper Methodes //////////////////////////
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

  Color? colorFirstOrderCancelButton(MQTTAppState appState) {
    if (double.parse(appState.getFirstOrderWeightText) > 0) {
      return null;
    } else {
      return Colors.red;
    }
  }

  Color? colorSecondOrderCancelButton(MQTTAppState appState) {
    if (double.parse(appState.getSecondOrderWeightText) > 0) {
      return null;
    } else {
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
    manager = MQTTManager(
        host: currentAppState.getHostIP,
        topic1: "order",
        topic2: "logListener",
        topic3: "firstWeightListener",
        topic4: "adminListener",
        topic5: "secondWeightListener",
        identifier: "BeanBotDemo",
        state: currentAppState,
        orderState: currentOrderState);
    manager.initializeMQTTClient();
    manager.connect();
    currentAppState.setMQTTManger(manager);
  }

  // Disconnects the app from the broker.
  void _disconnect() {
    manager.disconnect();
    currentAppState.setFirstOrderReceivedWeightText('0');
    currentOrderState.setFirstOrder('');
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
                  currentOrderState.setOrder(currentOrder);
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

  void _showEndOrderMessage() {
    showDialog(
      context: context, barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    "Your order of ${currentOrderState.getWeightOrder}g from ${currentOrderState.getSiloNumber.toLowerCase()} is ready."),
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

  bool disableFirstCancelOrder(MQTTAppState appState) {
    if (double.parse(appState.getFirstOrderWeightText) > 0) {
      return false;
    } else {
      return true;
    }
  }

  bool disableSecondCancelOrder(MQTTAppState appState) {
    if (double.parse(appState.getSecondOrderWeightText) > 0) {
      return false;
    } else {
      return true;
    }
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
