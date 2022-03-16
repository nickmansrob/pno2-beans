import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bean_bot/Providers/OrderState.dart';

import 'package:bean_bot/mqtt/MQTTManager.dart';
import 'package:bean_bot/Providers/MQTTAppState.dart';

// TODO: Delete check connection
// TODO: Make print IP work
// TODO: Investigate publishing

// weightListener for topic for currentWeight
// logListener for logs of the arduino

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);
  @override
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final _servoForm = GlobalKey<FormState>();

  late MQTTAppState currentAppState;
  late OrderState currentOrderState;
  late MQTTManager manager;

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
      ),
      body: ListView(children: [
        // Creates the connection indicator on top of the screen. \
        _buildConnectionStateText(
          _prepareStateMessageFrom(appState.getAppConnectionState),
          setColor(appState.getAppConnectionState),
        ),
        _buildManualOverrideState(appState.getAppConnectionState),
        _buildServoInput(),
        _buildMotorToggle(),
        _buildArduinoToggle(),
      ]),
    );
  }

  /////////////////////////// Widgets ///////////////////////////
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

  Widget _buildManualOverrideState(MQTTAppConnectionState connectionState) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                child: Text(
                  'Manual override',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, top: 8, right: 8, bottom: 0),
                  child: Switch(
                    value: appState.getIsSwitched,
                    onChanged: (value) {
                      if (!disableTextField(connectionState)) {
                        null;
                      } else {
                        setState(() {
                          appState.setIsSwitched(value);
                        });
                      }
                    },
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
    );
  }

  Widget _buildMotorToggle() {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
              child: Text(
                'Motors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: appState.getIsSwitched ? () {} : null,
                  child: const Text('Toggle 1'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: appState.getIsSwitched ? () {} : null,
                  child: const Text('Toggle 2'),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: appState.getIsSwitched ? () {} : null,
                  child: const Text('Toggle 3'),
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
    );
  }

  Widget _buildServoInput() {
    MQTTAppState appState = Provider.of<MQTTAppState>(context);
    return Form(
        key: _servoForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: const <Widget>[
                Padding(
                    padding:
                        EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 4),
                    child: Text(
                      'Servos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
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
                      enabled: appState.getIsSwitched,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Degrees servo 1',
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of degrees';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: ElevatedButton(
                      onPressed: appState.getIsSwitched ? () {} : null,
                      child: const Text('Apply'),
                    ),
                  ),
                ),
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
                      enabled: appState.getIsSwitched,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Degrees servo 2',
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of degrees';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: ElevatedButton(
                      onPressed: appState.getIsSwitched ? () {} : null,
                      child: const Text('Apply'),
                    ),
                  ),
                ),
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
                      enabled: appState.getIsSwitched,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Degrees servo 3',
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of degrees';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: ElevatedButton(
                      onPressed: appState.getIsSwitched ? () {} : null,
                      child: const Text('Apply'),
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
        ));
  }

  Widget _buildArduinoToggle() {
    return Column(children: [
      Row(
        mainAxisSize: MainAxisSize.max,
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 4),
            child: Text(
              'Arduino',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  _showRestoreConfirmMessage();
                  // Respond to button press
                },
                child: const Text('Restore'),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.red,
                  onSurface: Colors.redAccent,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  _showResetConfirmMessage();
                  // Respond to button press
                },
                child: const Text('Reset'),
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
    ]);
  }

  /////////////////////////// Helper functions ///////////////////////////
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

  // Function to disable textfields when not connected to the Arduino.
  bool disableTextField(MQTTAppConnectionState state) {
    if (state == MQTTAppConnectionState.disconnected ||
        state == MQTTAppConnectionState.connecting) {
      return false;
    } else {
      return true;
    }
  }

  /////////////////////////// Void ///////////////////////////
  @override
  void initState() {
    super.initState();
  }

  void _showResetConfirmMessage() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Arduino'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const [
                Text("You're about to reset the Arduino. Are you sure?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _publishMessage('reset', 'adminListener');
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

  void _showRestoreConfirmMessage() {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restore Bean Bot'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const [
                Text("You're about to restore the Bean Bot. Are you sure?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _publishMessage('restore', 'adminListener');
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

  void _publishMessage(String text, String topic) {
    final MQTTAppState appState =
        Provider.of<MQTTAppState>(context, listen: false);
    final OrderState orderState =
        Provider.of<OrderState>(context, listen: false);

    // Keep a reference to the app state and order.
    currentAppState = appState;
    currentOrderState = orderState;
    manager = currentAppState.getMQTTManager;
    manager.publish(text, topic);
  }
}
