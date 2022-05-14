import 'dart:math' as math;

import 'package:bean_bot/data/menu_items_home.dart';
import 'package:bean_bot/model/menu_item.dart';
import 'package:bean_bot/mqtt/mqtt_manager.dart';
import 'package:bean_bot/pages/debug.dart';
import 'package:bean_bot/pages/logs.dart';
import 'package:bean_bot/providers/color_calibration_state.dart';
import 'package:bean_bot/providers/mqtt_app_state.dart';
import 'package:bean_bot/providers/order_state.dart';
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
  final TextEditingController _weightTextController = TextEditingController();
  final TextEditingController _idTextController = TextEditingController();

  late MQTTManager manager;
  late MQTTAppState currentAppState;
  late OrderState currentOrderState;
  late ColorCalibrationState currentColorCalibrationState;

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
    final ColorCalibrationState calibrationState =
        Provider.of<ColorCalibrationState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    currentOrderState = orderState;
    currentColorCalibrationState = calibrationState;
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
          actions: <Widget>[
            PopupMenuButton<MenuItem>(
              onSelected: (item) => _onSelected(context, item),
              itemBuilder: (context) =>
                  [...MenuItems.items.map(buildItem).toList()],
            ),
          ],
        ),
        body: ListView(
          children: [
            _buildConnectionStateText(
              statusBarMessage(appState.getAppConnectionState),
              setColorStatusBar(appState.getAppConnectionState),
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
            if (currentAppState.getFirstOrderDone == 'done' && currentAppState.getSecondOrderDone == 'done')
              _buildReorderBeansButton(appState, orderState),
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
            ),
          ),
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
              enabled: (disableTextFields(state) &&
                  currentOrderState.getOrderCount < 2),
              controller: _weightTextController,
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
                onChanged: (disableTextFields(state) &&
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
                onChanged: (disableTextFields(state) &&
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
                onChanged: (disableTextFields(state) &&
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
              onPressed: (disableTextFields(state) &&
                      currentOrderState.getOrderCount < 2)
                  ? () {
                      // Dismisses keyboard
                      if (!disableTextFields(state)) {
                        null;
                      } else {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_weightForm.currentState!.validate()) {
                          currentOrderState
                              .setBothWeightOrder(_weightTextController.text);
                          currentOrderState
                              .setWeightOrder(_weightTextController.text);
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
              onPressed: (disableTextFields(state) &&
                      currentOrderState.getOrderCount < 2)
                  ? () {
                      _weightTextController.clear();
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
    _ipTextController.text = currentAppState.getHostIP;

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
          _showFirstEndOrderMessage();
          _publishMessage(currentAppState.getOrderMessage, 'order2');
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
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 0, top: 0, right: 0, bottom: 4),
                          child: Text(
                            'Color:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0, top: 0, right: 0, bottom: 8),
                          child: Container(
                            decoration: BoxDecoration(
                                color: appState.getFirstColor,
                                borderRadius: BorderRadius.circular(4.0)),
                            width: width - 32,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Current weight: ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${currentAppState.getFirstOrderWeightText}g.',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 0, top: 8, right: 0, bottom: 4),
                          child: Text(
                            'Progress:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0, top: 0, bottom: 8, right: 0),
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
                                        '${(firstWeightFraction * 100).toStringAsFixed(1)}%',
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
                                      orderState.disposeFirstOrder();
                                      appState.disposeFirstOrderAppState();
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

  // Builds the widget of the first order when it's finished.
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
      Future.delayed(
        Duration.zero,
        () {
          setState(
            () {
              currentOrderState.setSecondOrder('');
              _showSecondEndOrderMessage();
            },
          );
        },
      );
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 0, top: 0, right: 0, bottom: 4),
                          child: Text(
                            'Color:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0, top: 0, right: 0, bottom: 8),
                          child: Container(
                            decoration: BoxDecoration(
                                color: appState.getSecondColor,
                                borderRadius: BorderRadius.circular(4.0)),
                            width: width - 32,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Current weight: ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${currentAppState.getSecondOrderWeightText}g.',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 0, top: 8, right: 0, bottom: 4),
                          child: Text(
                            'Progress:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
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
                                        '${(secondWeightFraction * 100).toStringAsFixed(1)}%',
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
                                      orderState.disposeSecondOrder();
                                      appState.disposeSecondOrderAppState();
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

  // Builds the widget of the second order when it's finished.
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

  // Creates the button to clear out the logs.
  Widget _buildReorderBeansButton(MQTTAppState appState,
      OrderState orderState) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                appState.disposeAppState();
                orderState.disposeOrderState();
              },
              child: const Text('Reorder beans'),
            ),
          ),
        ),
      ],
    );
  }


  ////////////////////////// Helper Methods //////////////////////////
  // Gets the connection state and returns the associated string.
  String statusBarMessage(MQTTAppConnectionState state) {
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
  Color setColorStatusBar(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return Colors.green;
      case MQTTAppConnectionState.connecting:
        return Colors.deepOrange;
      case MQTTAppConnectionState.disconnected:
        return Colors.red;
    }
  }

  // Disables text-fields when not connected to the Arduino.
  bool disableTextFields(MQTTAppConnectionState state) {
    if (state == MQTTAppConnectionState.disconnected ||
        state == MQTTAppConnectionState.connecting) {
      return false;
    } else {
      return true;
    }
  }

  // Makes the cancel button in the order widget grey when disabled.
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

  // Returns false when the first order has started.
  bool disableFirstCancelOrder(MQTTAppState appState) {
    if (double.parse(appState.getFirstOrderWeightText) > 0) {
      return false;
    } else {
      return true;
    }
  }

  // Returns false when the second order has started.
  bool disableSecondCancelOrder(MQTTAppState appState) {
    if (double.parse(appState.getSecondOrderWeightText) > 0) {
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
    _weightTextController.clear();
  }

  // Clears the text of the IP controller.
  void disposeIpController() {
    _ipTextController.dispose();
    super.dispose();
  }

  // Connects the app to the broker.
  void _configureAndConnect() {
    manager = MQTTManager(
        host: currentAppState.getHostIP,
        topicList: [
          "order1",
          // sending 'done' for first order
          "order2",
          // sending 'done' for second order
          "logListener",
          // sending all log data from Arduino to log page
          "weight1",
          // sending weight data from Arduino to app for first order
          "weight2",
          // sending weight data form Arduino to app for second order
          "motor1",
          // 'toggle' and 'change_rotation' for first DC
          'motor2',
          // 'toggle' and 'change_rotation' for second DC
          'servo1',
          // degrees for first servo
          'servo2',
          // degrees for second servo
          'servo3',
          // degrees for third servo
          'servo4',
          // degrees for fourth servo
          'distControl',
          // for controlling ultrasonic sensor from app
          'colorControl',
          // for controlling color sensor from app
          'color1',
          // sending data from color sensor (RGB-triplet) from color sensor to app for first order
          'color2',
          // sending data from color sensor (RGB-triplet) from color sensor to app for second order
          'override',
          // '0' when manual override is not enabled, '1' when override is enabled
          'distanceListener',
          // used for listening to the read sensor.
          'colorData',
          // sending data from color sensor to app
          'weightData',
          // sending data from weight sensor to app
          'distData',
          // sending data from ultrasonic sensor to app
          'colorCal',
          // for sending data of the color sensor calibration between app and Arduino
          'rgb',
        ],
        identifier: currentAppState.getAppId,
        state: currentAppState,
        orderState: currentOrderState,
        colorCalibrationState: currentColorCalibrationState);
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
  void _onSelected(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.itemDebug:
        Navigator.pushNamed(context, '/debug');
        break;
      case MenuItems.itemLog:
        Navigator.pushNamed(context, '/logs');
        break;
      case MenuItems.itemColor:
        Navigator.pushNamed(context, '/color_calibration');
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
                  }

                  currentOrderState.setOrder(currentOrder);
                  currentOrderState
                      .setSiloNumber(currentOrderState.getSiloChoiceNumber);
                  currentOrderState.incrementOrderCount();
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

  // Opens a dialog box when the first order of the user is ready.
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

  // Opens a dialog box when the first order of the user is ready.
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

  // Opens a dialog box when the user manually disconnects from the broker.
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
