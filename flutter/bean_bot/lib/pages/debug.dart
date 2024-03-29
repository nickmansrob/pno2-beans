import 'package:bean_bot/data/menu_items_debug.dart';
import 'package:bean_bot/model/menu_item.dart';
import 'package:bean_bot/mqtt/mqtt_manager.dart';
import 'package:bean_bot/providers/mqtt_app_state.dart';
import 'package:bean_bot/providers/order_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  /////////////////////////// Variables ///////////////////////////
  final _servoForm1 = GlobalKey<FormState>();
  final _servoForm2 = GlobalKey<FormState>();
  final _servoForm3 = GlobalKey<FormState>();
  final _servoForm4 = GlobalKey<FormState>();

  final _rForm = GlobalKey<FormState>();
  final _gForm = GlobalKey<FormState>();
  final _bForm = GlobalKey<FormState>();

  late MQTTAppState currentAppState;
  late OrderState currentOrderState;
  late MQTTManager manager;

  final TextEditingController _firstServoController = TextEditingController();
  final TextEditingController _secondServoController = TextEditingController();
  final TextEditingController _thirdServoController = TextEditingController();

  final TextEditingController _rController = TextEditingController();
  final TextEditingController _gController = TextEditingController();
  final TextEditingController _bController = TextEditingController();

  /////////////////////////// Widgets ///////////////////////////
  // Builds the main widget of the debug page.
  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
        actions: <Widget>[
          PopupMenuButton<MenuItem>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [...MenuItems.items.map(buildItem).toList()],
          ),
        ],
      ),
      body: ListView(children: [
        // Creates the connection indicator on top of the screen.
        _buildConnectionStateText(
          statusBarMessage(appState.getAppConnectionState),
          setColorStatusBar(appState.getAppConnectionState),
        ),
        _buildManualOverrideState(appState.getAppConnectionState),
        _buildServoInput(),
        _buildMotorToggle(),
        _buildSensors(appState),
        _buildArduinoToggle(),
      ]),
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

  // Creates the manual override switch.
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
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
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

  // Creates to forms for the input for the servo motors.
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
                      padding: EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 4),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: appState.getIsSwitched
                            ? () {
                                if (_servoForm1.currentState!.validate()) {
                                  _publishMessage(_firstServoController.text, 'servo1');
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: ElevatedButton(
                    onPressed: appState.getIsSwitched
                        ? () {
                            if (_servoForm2.currentState!.validate()) {
                              _publishMessage(_secondServoController.text, 'servo2');
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: ElevatedButton(
                    onPressed: appState.getIsSwitched
                        ? () {
                            if (_servoForm3.currentState!.validate()) {
                              _publishMessage(_thirdServoController.text, 'servo3');
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Servo 3',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: appState.getIsSwitched
                          ? () {
                              _publishMessage('0', 'servo3');
                            }
                          : null,
                      child: const Text('CCW'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: appState.getIsSwitched
                          ? () {
                              _publishMessage('90', 'servo3');
                            }
                          : null,
                      child: const Text('Stop'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: appState.getIsSwitched
                          ? () {
                              _publishMessage('80', 'servo3');
                            }
                          : null,
                      child: const Text('CW'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Creates the DC-motor input
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Motor 1',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
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
                                        _publishMessage('change_rotation', 'motor1');
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
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Motor 2',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                                      _publishMessage('change_rotation', 'motor2');
                                    }
                                  : null,
                              child: const Text('Change rotation'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
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

  // Creates the widgets for the color sensor and the ultrasonic sensor.
  Widget _buildSensors(MQTTAppState appState) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
              child: Text(
                'Sensors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'Ultrasonic sensor',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                                        _publishMessage('readUltra', 'distControl');
                                      }
                                    : null,
                                child: const Text('Start reading'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: appState.getIsSwitched
                                    ? () {
                                        _publishMessage('stopUltra', 'distControl');
                                      }
                                    : null,
                                child: const Text('Stop reading'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 8),
                            child: Center(
                              child: Text('Distance [cm]: ${currentAppState.getDistance}.'),
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
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Color sensor',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: appState.getIsSwitched
                                        ? () {
                                            _publishMessage('readColor', 'colorControl');
                                          }
                                        : null,
                                    child: const Text('Start reading'),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: appState.getIsSwitched
                                        ? () {
                                            _publishMessage('stopColor', 'colorControl');
                                          }
                                        : null,
                                    child: const Text('Stop reading'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: appState.getColorDebug, borderRadius: BorderRadius.circular(4.0)),
                                  width: width - 32,
                                  height: 30,
                                ),
                              ),
                            ],
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
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'Weight sensor',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                                        _publishMessage('readWeight', 'weightControl');
                                      }
                                    : null,
                                child: const Text('Start reading'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: appState.getIsSwitched
                                    ? () {
                                        _publishMessage('stopWeight', 'weightControl');
                                      }
                                    : null,
                                child: const Text('Stop reading'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 8),
                            child: Center(
                              child: Text('Weight [g]: ${currentAppState.getWeight}.'),
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
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'RGB Led',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Form(
                                key: _rForm,
                                child: Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    child: TextFormField(
                                      enabled: appState.getIsSwitched,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Red',
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(10),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      controller: _rController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the red value';
                                        }
                                        if (int.parse(value) > 255 || int.parse(value) < 0) {
                                          return 'Between 0 and 255!';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Form(
                                key: _gForm,
                                child: Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    child: TextFormField(
                                      enabled: appState.getIsSwitched,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Green',
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(10),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      controller: _gController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the green value';
                                        }
                                        if (int.parse(value) > 255 || int.parse(value) < 0) {
                                          return 'Between 0 and 255!';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Form(
                                key: _bForm,
                                child: Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    child: TextFormField(
                                      enabled: appState.getIsSwitched,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Blue',
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(10),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      controller: _bController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the blue value';
                                        }
                                        if (int.parse(value) > 255 || int.parse(value) < 0) {
                                          return 'Between 0 and 255!';
                                        }
                                        return null;
                                      },
                                    ),
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
                                    onPressed: appState.getIsSwitched
                                        ? () {
                                            if (_rForm.currentState!.validate() &&
                                                _gForm.currentState!.validate() &&
                                                _bForm.currentState!.validate()) {
                                              _publishMessage(
                                                  sendRGB(_rController.text, _gController.text, _bController.text),
                                                  'rgb');
                                            }
                                          }
                                        : null,
                                    child: const Text('Set color'),
                                  ),
                                ),
                              ),
                            ],
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

  // Creates the widgets for resetting and restoring the Arduino and Bean Bot.
  Widget _buildArduinoToggle() {
    return Column(
      children: [
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
                    _showAbortConfirmationMessage(currentAppState);
                    // Respond to button press
                  },
                  child: const Text('Abort!'),
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
    );
  }

  /////////////////////////// Helper functions ///////////////////////////
  // Gets the color of the status bar on top of the screen.
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

  // Gets the message for the status bar on top of the screen.
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

  // Gets the RBG-values for sending them to the RGB-led.
  String sendRGB(String r, String g, String b) {
    if (r.length < 3 || g.length < 3 || b.length < 3) {
      while (r.length != 3) {
        r = '0' + r;
      }
      while (g.length != 3) {
        g = '0' + g;
      }
      while (b.length != 3) {
        b = '0' + b;
      }
    }
    return r + g + b;
  }

  // Function to disable text-fields when not connected to the broker.
  bool disableTextField(MQTTAppConnectionState state) {
    if (state == MQTTAppConnectionState.disconnected || state == MQTTAppConnectionState.connecting) {
      return false;
    } else {
      return true;
    }
  }

  // Function to convert a RGB-triplet to a color, specified in RGB.
  Color convertRGBtoColor(String colorInt) {
    List intList = [
      int.parse(colorInt.substring(0, 3)),
      int.parse(colorInt.substring(3, 6)),
      int.parse(colorInt.substring(6, 9))
    ];
    return Color.fromRGBO(intList[0], intList[1], intList[2], 1);
  }

  /////////////////////////// Voids ///////////////////////////
  @override
  void initState() {
    super.initState();
  }

  //// Navigation Menu
  // Handles the navigation of the popupmenu.
  void onSelected(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.itemLog:
        Navigator.popAndPushNamed(context, '/logs');
        break;
      case MenuItems.itemColor:
        Navigator.popAndPushNamed(context, '/color_calibration');
        break;
    }
  }

  // Creates the navigation menu.
  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem(
        value: item,
        child: Text(item.text),
      );

  // Creates a dialog box when the user wants to restore the Bean Bot.
  void _showAbortConfirmationMessage(MQTTAppState currentAppState) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restore Bean Bot'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const [
                Text("You're about to abort te normalFlow()! Are you sure?"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _publishMessage('stop', 'stop');
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

  // Publishes message on MQTT.
  void _publishMessage(String text, String topic) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context, listen: false);
    final OrderState orderState = Provider.of<OrderState>(context, listen: false);

    // Keep a reference to the app state and order.
    currentAppState = appState;
    currentOrderState = orderState;
    manager = currentAppState.getMQTTManager;
    manager.publish(text, topic);
  }
}
