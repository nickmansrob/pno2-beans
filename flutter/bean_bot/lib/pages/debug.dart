import 'package:bean_bot/Providers/mqtt_app_state.dart';
import 'package:bean_bot/Providers/order_state.dart';
import 'package:bean_bot/mqtt/mqtt_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final _servoForm1 = GlobalKey<FormState>();
  final _servoForm2 = GlobalKey<FormState>();
  final _servoForm3 = GlobalKey<FormState>();
  final _servoForm4 = GlobalKey<FormState>();

  late MQTTAppState currentAppState;
  late OrderState currentOrderState;
  late MQTTManager manager;

  final TextEditingController _firstServoController = TextEditingController();
  final TextEditingController _secondServoController = TextEditingController();
  final TextEditingController _thirdServoController = TextEditingController();
  final TextEditingController _fourthServoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
      ),
      body: ListView(children: [
        // Creates the connection indicator on top of the screen.
        _buildConnectionStateText(
          _prepareStateMessageFrom(appState.getAppConnectionState),
          setColor(appState.getAppConnectionState),
        ),
        _buildManualOverrideState(appState.getAppConnectionState),
        _buildServoInput(),
        _buildMotorToggle(),
        _buildSensors(),
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
                          if (value == false) {
                            _publishMessage('0', 'override');
                          } else {
                            _publishMessage('1', 'override');
                          }
                        });
                      }
                      if (value == false) {
                        _firstServoController.text = '';
                        _secondServoController.text = '';
                        _thirdServoController.text = '';
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

  Widget _buildServoInput() {
    MQTTAppState appState = Provider.of<MQTTAppState>(context);
    return Column(
      children: [
        Form(
          key: _servoForm1,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: TextFormField(
                        enabled: appState.getIsSwitched,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Degrees servo 1',
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        keyboardType: TextInputType.phone,
                        controller: _firstServoController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of degrees';
                          }
                          if (int.parse(value) > 180 || int.parse(value) < 0) {
                            return 'Between 0 and 180!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: appState.getIsSwitched
                            ? () {
                                if (_servoForm1.currentState!.validate()) {
                                  _publishMessage(
                                      _firstServoController.text, 'servo1');
                                }
                              }
                            : null,
                        child: const Text('Apply'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Form(
          key: _servoForm2,
          child: Row(
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
                    controller: _secondServoController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of degrees';
                      }
                      if (int.parse(value) > 180 || int.parse(value) < 0) {
                        return 'Between 0 and 180!';
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
                    onPressed: appState.getIsSwitched
                        ? () {
                            if (_servoForm2.currentState!.validate()) {
                              _publishMessage(
                                  _secondServoController.text, 'servo2');
                            }
                          }
                        : null,
                    child: const Text('Apply'),
                  ),
                ),
              ),
            ],
          ),
        ),
        Form(
          key: _servoForm3,
          child: Row(
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
                    controller: _thirdServoController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of degrees';
                      }
                      if (int.parse(value) > 180 || int.parse(value) < 0) {
                        return 'Between 0 and 180!';
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
                    onPressed: appState.getIsSwitched
                        ? () {
                            if (_servoForm3.currentState!.validate()) {
                              _publishMessage(
                                  _thirdServoController.text, 'servo3');
                            }
                          }
                        : null,
                    child: const Text('Apply'),
                  ),
                ),
              ),
            ],
          ),
        ),
        Form(
          key: _servoForm4,
          child: Row(
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
                      hintText: 'Degrees servo 4',
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                    ),
                    keyboardType: TextInputType.phone,
                    controller: _thirdServoController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of degrees';
                      }
                      if (int.parse(value) > 180 || int.parse(value) < 0) {
                        return 'Between 0 and 180!';
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
                    onPressed: appState.getIsSwitched
                        ? () {
                            if (_servoForm3.currentState!.validate()) {
                              _publishMessage(
                                  _thirdServoController.text, 'servo4');
                            }
                          }
                        : null,
                    child: const Text('Apply'),
                  ),
                ),
              ),
            ],
          ),
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
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'Motor 1',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: appState.getIsSwitched
                                    ? () {
                                        _publishMessage('toggle', 'motor1');
                                      }
                                    : null,
                                child: const Text('Toggle'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: appState.getIsSwitched
                                    ? () {
                                        _publishMessage(
                                            'change_rotation', 'motor1');
                                      }
                                    : null,
                                child: const Text('Change rotation'),
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
          ],
        ),
        const Divider(
          indent: 8,
          endIndent: 8,
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'Motor 2',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: appState.getIsSwitched
                                    ? () {
                                        _publishMessage('toggle', 'motor2');
                                      }
                                    : null,
                                child: const Text('Toggle'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: appState.getIsSwitched
                                    ? () {
                                        _publishMessage(
                                            'change_rotation', 'motor2');
                                      }
                                    : null,
                                child: const Text('Change rotation'),
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
          ],
        ),
        const Divider(
          indent: 8,
          endIndent: 8,
        ),
      ],
    );
  }

  Widget _buildSensors() {
    return Column(children: [
      Row(
        mainAxisSize: MainAxisSize.max,
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 4),
            child: Text(
              'Ultrasonic Sensor',
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
                  _publishMessage('read', 'readUltrasonic');
                  // Respond to button press
                },
                child: const Text('Start Reading'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  _publishMessage('stop', 'readUltrasonic');
                  // Respond to button press
                },
                child: const Text('Stop reading'),
              ),
            ),
          ),
        ],
      ),
      const Divider(
        indent: 8,
        endIndent: 8,
      ),
      Row(
        mainAxisSize: MainAxisSize.max,
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 4),
            child: Text(
              'Color sensor',
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
                  _publishMessage('read_color', 'readColor');
                  // Respond to button press
                },
                child: const Text('Start color'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  _publishMessage('stop_color', 'readColor');
                  // Respond to button press
                },
                child: const Text('Stop color'),
              ),
            ),
          ),
        ],
      ),
      const Divider(indent: 8, endIndent: 9),
    ]);
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
                  _showRestoreConfirmMessage(currentAppState);
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
                  _showResetConfirmMessage(currentAppState);
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

  /////////////////////////// Voids ///////////////////////////
  @override
  void initState() {
    super.initState();
  }

  void _showResetConfirmMessage(MQTTAppState currentAppState) {
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
                currentAppState.setResetPressed(true);
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

  void _showRestoreConfirmMessage(MQTTAppState currentAppState) {
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
                currentAppState.setRestorePressed(true);
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
