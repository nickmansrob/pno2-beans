import 'dart:math' as math;

import 'package:bean_bot/Providers/mqtt_app_state.dart';
import 'package:bean_bot/Providers/order_state.dart';
import 'package:bean_bot/data/menu_items.dart';
import 'package:bean_bot/model/menu_item.dart';
import 'package:bean_bot/mqtt/mqtt_manager.dart';
import 'package:bean_bot/pages/debug.dart';
import 'package:bean_bot/pages/logs.dart';
import 'package:expansion_widget/expansion_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final _idForm = GlobalKey<FormState>();

  final TextEditingController _ipTextController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _idTextController = TextEditingController();

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
            if (currentAppState.getFirstOrderDone == 'done')
              _buildFirstOrderDone(currentOrderState),
            if (currentOrderState.getSecondOrder != '')
              _buildSecondOrder(currentAppState, currentOrderState),
            if (currentAppState.getSecondOrderDone == 'done')
              _buildSecondOrderDone(currentOrderState),
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
    return Form(
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
              enabled: (disableTextField(state) &&
                  currentOrderState.getOrderCount < 2),
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
                  if (currentOrderState.getSiloChoiceNumber == '') {
                    return 'Please enter a silo number.';
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
                groupValue: currentOrderState.getSiloChoiceNumber,
                onChanged: (disableTextField(state) &&
                    currentOrderState.getOrderCount < 2)
                    ? (value) {
                  setState(
                        () {
                      currentOrderState
                          .setSiloChoiceNumber(value.toString());
                      currentOrderState.setSiloChoiceNumber(
                          currentOrderState.getSiloChoiceNumber);
                    },
                  );
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
                groupValue: currentOrderState.getSiloChoiceNumber,
                onChanged: (disableTextField(state) &&
                    currentOrderState.getOrderCount < 2)
                    ? (value) {
                  setState(
                        () {
                      currentOrderState
                          .setSiloChoiceNumber(value.toString());
                      currentOrderState.setSiloChoiceNumber(
                          currentOrderState.getSiloChoiceNumber);
                    },
                  );
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
                groupValue: currentOrderState.getSiloChoiceNumber,
                onChanged: (disableTextField(state) &&
                    currentOrderState.getOrderCount < 2)
                    ? (value) {
                  setState(
                        () {
                      currentOrderState
                          .setSiloChoiceNumber(value.toString());
                      currentOrderState.setSiloChoiceNumber(
                          currentOrderState.getSiloChoiceNumber);
                    },
                  );
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
              onPressed: (disableTextField(state) &&
                  currentOrderState.getOrderCount < 2)
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
              onPressed: (disableTextField(state) &&
                  currentOrderState.getOrderCount < 2)
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

  // Builds the widget to enter the IP address.
  Widget _buildAdminInput() {
    _idTextController.text = currentAppState.getAppId;

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
          content: Column(
            children: [
              Form(
                key: _idForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8, top: 0, right: 8, bottom: 8),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'App MQTT id',
                                isDense: true,
                                contentPadding: EdgeInsets.all(10),
                              ),
                              controller: _idTextController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the ID for the app.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Form(
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
                                if (_adminForm.currentState!.validate() &&
                                    _idForm.currentState!.validate()) {
                                  if (currentAppState.getAppConnectionState ==
                                      MQTTAppConnectionState.disconnected) {
                                    currentAppState
                                        .setAppId(_idTextController.text);
                                    currentAppState
                                        .setHostIp(_ipTextController.text);
                                    _configureAndConnect();
                                  }
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
                                  currentAppState
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
            ],
          ),
        ),
      ),
    );
  }

  // Builds the heading of the order menu.
  Widget _buildOrderText() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 6),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Orders (${currentOrderState.getOrderCount}/2)',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Builds a widget which displays the first order.
  Widget _buildFirstOrder(MQTTAppState appState, OrderState orderState) {
    double width = MediaQuery.of(context).size.width;

    VoidCallback? callBack() {
      Future.delayed(Duration.zero, () {
        setState(() {
          currentOrderState.setFirstOrder('');
          currentAppState.setFirstOrderReceivedDone('');
          _showFirstEndOrderMessage();
        });
      });
      return null;
    }

    if (double.tryParse(currentOrderState.getFirstWeightOrder) != null &&
        double.tryParse(currentAppState.getFirstOrderWeightText) != 0 &&
        double.parse(currentOrderState.getFirstWeightOrder) <=
            double.parse(currentAppState.getFirstOrderWeightText)) {
      firstWeightFraction = 1.0;
    } else if (double.tryParse(currentOrderState.getFirstWeightOrder) != null &&
        double.parse(currentAppState.getFirstOrderWeightText) != 0.0) {
      firstWeightFraction =
          double.parse(currentAppState.getFirstOrderWeightText) /
              double.parse(currentOrderState.getFirstWeightOrder);
    }

    if (currentAppState.getFirstOrderReceivedDone == 'done') {
      callBack();
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 2),
                          child: Text(
                              'Color: ${currentAppState.getFirstColor}.',
                              style: const TextStyle(fontSize: 15)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            'Current weight: ${currentAppState.getFirstOrderWeightText}g.',
                            style: const TextStyle(fontSize: 15)),
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
                                    width: width - 32,
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
                                _publishMessage('0000', 'order1');
                                orderState.setFirstOrder('');
                                orderState.decrementOrderCount();
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

  Widget _buildFirstOrderDone(OrderState orderState) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'Order 1: done.',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a widget which displays the second order.
  Widget _buildSecondOrder(MQTTAppState appState, OrderState orderState) {
    final int orderNumber;

    VoidCallback? callBack() {
      Future.delayed(Duration.zero, () {
        setState(() {
          currentOrderState.setSecondOrder('');
          currentAppState.setSecondOrderReceivedDone('');
          _showSecondEndOrderMessage();
        });
      });
      return null;
    }

    double width = MediaQuery.of(context).size.width;
    if (double.tryParse(currentOrderState.getSecondWeightOrder) != null &&
        double.tryParse(currentAppState.getSecondOrderWeightText) != 0 &&
        double.parse(currentOrderState.getSecondWeightOrder) <=
            double.parse(currentAppState.getSecondOrderWeightText)) {
      secondWeightFraction = 1.0;
    } else if (double.tryParse(currentOrderState.getSecondWeightOrder) !=
        null &&
        double.parse(currentOrderState.getSecondWeightOrder) > 0.0) {
      secondWeightFraction =
          double.parse(currentAppState.getSecondOrderWeightText) /
              double.parse(currentOrderState.getSecondWeightOrder);
    }

    if (currentAppState.getSecondOrderReceivedDone == 'done') {
      callBack();
    }

    if (currentOrderState.getFirstOrder == '' &&
        currentOrderState.getSecondOrder != '' &&
        currentAppState.getFirstOrderDone != 'done') {
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
                      ),
                    ],
                  ),
                ));
          },
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 2),
                          child: Text(
                            'Color: ${currentAppState.getSecondColor}.',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 2),
                          child: Text(
                            'Current weight: ${currentAppState.getSecondOrderWeightText}g.',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
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
                                      height: 28,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                    width: width - 32,
                                    height: 30,
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
                                _publishMessage('0000', 'order2');
                                orderState.setSecondOrder('');
                                orderState.decrementOrderCount();
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

  Widget _buildSecondOrderDone(OrderState orderState) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'Order 2: done.',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////// Helper Methods //////////////////////////

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

  // Makes the cancel button in the order menu grey when disabled.
  Color? colorFirstOrderCancelButton(MQTTAppState appState) {
    if (double.parse(appState.getFirstOrderWeightText) > 0) {
      return null;
    } else {
      return Colors.red;
    }
  }

  // Makes the cancel button in the order menu grey when disabled.
  Color? colorSecondOrderCancelButton(MQTTAppState appState) {
    if (double.parse(appState.getSecondOrderWeightText) > 0) {
      return null;
    } else {
      return Colors.red;
    }
  }

  // Disables text-fields when not connected to the Arduino.
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

  // Returns false when the first order has started.
  bool disableFirstCancelOrder(MQTTAppState appState) {
    if (double.parse(appState.getFirstOrderWeightText) > 0) {
      return false;
    } else {
      return true;
    }
  }

  // Returns true when the first order has started.
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

  /////////////////////////// Voids ///////////////////////////
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
        topicList: [
          "order1",
          "order2",
          "logListener",
          "firstWeightListener",
          "secondWeightListener",
          'adminListener',
          "motor1",
          'motor2',
          'servo1',
          'servo2',
          'servo3',
          'servo4',
          'readUltrasonic',
          'readColor',
          'firstColorListener',
          'secondColorListener',
          'override'
        ],
        identifier: currentAppState.getAppId,
        state: currentAppState,
        orderState: currentOrderState);
    manager.initializeMQTTClient();
    manager.connect();
    currentAppState.setMQTTManger(manager);
  }

  // Disconnects the app from the broker.
  void _disconnect() {
    manager.disconnect();
    currentAppState.disposeSecondOrderAppState();
    currentOrderState.disposeSecondOrder();
    _showDisconnectionMessage();
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
                    "You're about to order ${currentOrderState.getWeightOrder}g of ${currentOrderState.getSiloChoiceNumber.toLowerCase()}. Are you sure? Click OK to continue. Press Cancel to cancel the order."),
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
                  switch (currentOrderState.getSiloChoiceNumber) {
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

                  currentAppState.setOrderMessage(
                      beanWeightIndex + currentOrderState.getWeightOrder);

                  String currentOrder =
                      '${currentOrderState.getWeightOrder}g of ${currentOrderState.getSiloChoiceNumber.toLowerCase()}';

                  if (currentOrderState.getFirstOrder == '' &&
                      currentOrderState.getSecondOrder == '') {
                    _publishMessage(currentAppState.getOrderMessage, "order1");
                  } else if (currentOrderState.getFirstOrder != '' &&
                      currentOrderState.getSecondOrder == '') {
                    _publishMessage(currentAppState.getOrderMessage, "order2");
                  }
                  currentOrderState.setOrder(currentOrder);
                  currentOrderState
                      .setSiloNumber(currentOrderState.getSiloChoiceNumber);
                  currentOrderState.incementOrderCount();
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

  // Shows a message when the order of the user is ready.
  void _showFirstEndOrderMessage() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    "Your order of ${currentOrderState.getFirstWeightOrder}g beans from ${currentOrderState.getFirstSiloNumber.toLowerCase()} is ready."),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                currentOrderState.disposeFirstOrder();
                currentAppState.disposeFirstOrderAppState();
                Navigator.of(context, rootNavigator: true).maybePop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSecondEndOrderMessage() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    "Your order of ${currentOrderState.getSecondWeightOrder}g beans from ${currentOrderState.getSecondSiloNumber.toLowerCase()} is ready."),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                currentOrderState.disposeSecondOrder();
                currentAppState.disposeSecondOrderAppState();
                Navigator.of(context, rootNavigator: true).maybePop();
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
                    "You've ordered ${currentOrderState.getWeightOrder}g of ${currentOrderState.getSiloChoiceNumber.toLowerCase()}."),
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

  void _showDisconnectionMessage() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disconnection'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const [
                Text(
                    "The app disconnected from the broker. If the Bean Bot is processing an order, it will finish."),
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
